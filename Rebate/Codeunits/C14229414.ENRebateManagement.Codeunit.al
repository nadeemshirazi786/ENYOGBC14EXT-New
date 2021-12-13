codeunit 14229414 "Rebate Management ELA"
{

    // ENRE1.00 2021-08-20 AJ
    //    - Post Rebate Type to the Rebate Ledger and Posted Rebate Ledger
    //    - Added code to CalcRebate to clear variable if Include = No, in order to check sub types
    //    - add code to control which unit prifce to use
    //    - Added code to CalcRebate, new boolean field to ensure item rebate should/not apply.
    //     - add SkipDialogMode function; allows AccrueRebateToCustomer to run with defaults
    //     (i.e. as a scheduled nightly routine via report 23019640 "Post Scheduled Rebate Entries")
    //     - use optimized G/L key for AccrueRebateToCustomer
    //    - fix issue for negative sales document lines
    //  - RA Price Calculation Addition
    //    - Created function named CalcSalesDocLineRebate (this will not loop through all lines....)
    //    - Modified code in function named CalcSalesDocLineRebate to filter on line accordingly (a fix)
    //    - Modified CreateRebateEntry, if posted invoice or shipment, needed that reference before
    //         trying to populate Ship-to Code, otherwise it Source Type was Quote, and never found invoice or shipment.
    //    - Modified rebate code
    //    - change recordref usage to use fieldrefs when accessing vlaues from fields
    //    - Modifed CalcRebate, document dimension get would fail due to Document Type
    //    - add blocked customer handling to lump sum distribution
    //    - add new paramter pcodCurrencyCode to function CreateRebateEntry, plus code to populate two new currency code fields
    //    - fix: AccrueRebateToCustomer wasn't setting Currency Code
    //   Added Logic to Copy Job & Job Task No. from Job Task to Rebate Header on Creation of Rebate from Job Task Form for Promotional Job
    // 
    // 
    //    - fix an issue where using dimensions for rebate criteria would not work from posted documents
    // 
    // 
    //    - new functions: CalcAmount, CalcRebateAmount, CreateRebateAdjustment
    // 
    // 
    //    - Below Functions Modified
    //              - CalcSalesDocRebate
    //              - CalcSalesDocLineRebate
    // 
    // 
    //    - New Functions
    //              - CalcRebateFromRebateCode
    // 
    // 
    //    - new variable gdteOrderDate
    //            - code to handle commodity rebates
    // 
    // 
    // 
    //     - calculate Sales-Based Purchase (Vendor) rebates against the document too
    //     - new function BypassPurchRebates determines whether this is triggered as follows:
    //         1. Calculate Rebates on a Sales Document (ALWAYS)
    //         2. Release a Sales Document (if P&P Calc. Sales-Based on Release is TRUE)
    //         3. Post a Sales Document (if P&P Calc. Sales-Based on Invoice is TRUE)
    //         4. Periodic routine: Calculate Purch. Rebates
    //         ( 5. Periodic routine: Calculate Rebates (NEVER) )
    // 
    // 
    //    - commodity replace functionality modified
    // 
    // 
    //    - new function CalcOpenCommodityUsed
    //     - code to calculate open commodity entries; code to populate source fields
    // 
    // 
    //    - modified code for commodity to try replaces before partial
    // 
    // 
    //    - modified commodity code, if commodity cant fulfill, try replacement, then if not replacemnet
    //              use partial of initial commodity.
    //            - new function CalcCurrentDocCommodityUsed
    // 
    // 
    //    - modified commodity for catch weight items to use average
    // 
    // 
    //    - modified CalcAmount and CalcRebateAmount to be document level not lone level
    // 
    //    - modified commodity allocation to use vendor from manufacturer, based on manf setup on item
    //   - add Variable Weight support to $/Unit Rebate calculation
    //   - fix Variable Weight support to $/Unit Rebate calculation for posted documents
    //   - fix for "Rebate Date Source"::"Order Date" for unapplied Credit Memo posting (use Posting Date instead)
    //   - Fix issue with false rebate consume
    //   - Added publisher rdOnBeforeFilterLines

    Permissions = TableData "Cust. Ledger Entry" = rimd;

    trigger OnRun()
    begin
    end;

    var
        grecSalesSetup: Record "Sales & Receivables Setup";
        grecRebateHeaderFilter: Record "Rebate Header ELA";
        gblnUseDefaultPostingValues: Boolean;
        gdteOrderDate: Date;
        grecCommodityLedgerTemp: Record "Commodity Ledger ELA" temporary;
        gcduCWMgt: Codeunit "Rebate Sales Functions ELA";
        gblnBypassPurchRebates: Boolean;
        gcduPurchRebateMgmt: Codeunit "Purchase Rebate Management ELA";


    procedure CalcRebate(prrfLine: RecordRef; pblnPeriodicCalc: Boolean; var precTempRebateEntry: Record "Rebate Entry ELA")
    var
        lrecRebateLine: Record "Rebate Line ELA";
        lrecTempRebateLine: Record "Rebate Line ELA" temporary;
        lrecCustomer: Record Customer;
        lrecItem: Record Item;
        lcodLastRebate: Code[20];
        lrecSalesperson: Record "Salesperson/Purchaser";
        lrecSalesHeader: Record "Sales Header";
        lcodSalesperson: Code[20];
        lrecRebate: Record "Rebate Header ELA";
        lrecTempRebate: Record "Rebate Header ELA" temporary;
        lblnIsExclusion: Boolean;
        lblnIsApplicableCustomer: Boolean;
        lblnIsApplicableSalesperson: Boolean;
        lblnIsApplicableItem: Boolean;
        lrecRebateDetailTEMP: Record "Rebate Line ELA" temporary;
        lblnOverrideItemProperties: Boolean;
        lblnFoundCustOverride: Boolean;
        lblnFoundItemOverride: Boolean;
        lblnFoundSalespersonOverride: Boolean;
        lrecGLSetup: Record "General Ledger Setup";
        lrecDimValue: Record "Dimension Value";
        lblnIsApplicableEntity: Boolean;
        lblnFoundEntityOverride: Boolean;
        lcodEntity: Code[20];
        lblnFoundHit: Boolean;
        lblnspecificitemsdefined: Boolean;
        lrecSalesInvHeader: Record "Sales Invoice Header";
        lblnItemGroup: Boolean;
        lblnItemRebateGroup: Boolean;
        lblnItemCategoryCode: Boolean;
        lintTableNo: Integer;
        lfrfDocType: FieldRef;
        lfrfDocNo: FieldRef;
        ltxtFilter: Text[1024];
        lrecSalesCrMemoHdr: Record "Sales Cr.Memo Header";
        lrecReturnReceiptHdr: Record "Return Receipt Header";
        lfrfOrderDate: FieldRef;
        ldteOrderDate: Date;
        lcodShiptoCode: Code[10];
        lintLineNo: Integer;
        lfrfRefItemNo: FieldRef;
        ldecLineLevelRebateValue: Decimal;
        lblnItemExists: Boolean;
        lblnIsReturnOrder: Boolean;
        lfrfFieldRef: FieldRef;
        lfrfFieldRef2: FieldRef;
        lintDocType: Integer;
        lcodDimValueCodeToUse: Code[20];
        lcodDocNo: Code[20];
        lrecTempDimSetEntry: Record "Dimension Set Entry" temporary;
        lrecSalesLine: Record "Sales Line";
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
        DimMgt: Codeunit DimensionManagement;
    begin
        Clear(ldteOrderDate);


        //<ENRE1.00>
        grecCommodityLedgerTemp.Reset;
        grecCommodityLedgerTemp.DeleteAll;
        //</ENRE1.00>


        //<ENRE1.00>
        lblnIsReturnOrder := false;
        //</ENRE1.00>

        grecSalesSetup.Get;

        lintTableNo := prrfLine.Number;

        //<ENRE1.00>
        lfrfFieldRef := prrfLine.Field(4);
        Evaluate(lintLineNo, Format(lfrfFieldRef.Value));
        //</ENRE1.00>

        case lintTableNo of
            37:
                begin              //Sales Line
                    lfrfDocType := prrfLine.Field(1);
                    lfrfDocNo := prrfLine.Field(3);
                    lrecSalesHeader.SetFilter("Document Type", Format(lfrfDocType.Value));
                    lrecSalesHeader.SetFilter("No.", Format(lfrfDocNo.Value));

                    if not lrecSalesHeader.FindFirst then
                        exit;

                    //<ENRE1.00>
                    lcodShiptoCode := lrecSalesHeader."Ship-to Code";
                    lcodSalesperson := lrecSalesHeader."Salesperson Code";
                    //</ENRE1.00>

                    if Format(lfrfDocType.Value) = '3' then begin //Cr. Memo
                                                                  //<ENRE1.00>
                        lfrfFieldRef := prrfLine.Field(14228851); //ENRE1.00 //02

                        if Format(lfrfFieldRef.Value) = '' then
                            exit;
                        //</ENRE1.00>

                        //-- If not applied, use the Order Date field if not blank
                        if lrecSalesHeader."Applies-to Doc. No." = '' then begin
                            case grecSalesSetup."Rebate Date Source ELA" of
                                grecSalesSetup."Rebate Date Source ELA"::"Order Date":
                                    begin
                                        if lrecSalesHeader."Order Date" = 0D then
                                            exit;

                                        ldteOrderDate := lrecSalesHeader."Order Date";
                                    end;
                                grecSalesSetup."Rebate Date Source ELA"::"Shipment Date":
                                    begin
                                        if lrecSalesHeader."Shipment Date" = 0D then
                                            exit;

                                        ldteOrderDate := lrecSalesHeader."Shipment Date";
                                    end;
                            end;
                        end else begin
                            if not lrecSalesInvHeader.Get(lrecSalesHeader."Applies-to Doc. No.") then
                                exit;

                            case grecSalesSetup."Rebate Date Source ELA" of
                                grecSalesSetup."Rebate Date Source ELA"::"Order Date":
                                    begin
                                        if lrecSalesInvHeader."Order Date" = 0D then
                                            exit;

                                        ldteOrderDate := lrecSalesInvHeader."Order Date";
                                    end;
                                grecSalesSetup."Rebate Date Source ELA"::"Shipment Date":
                                    begin
                                        if lrecSalesInvHeader."Shipment Date" = 0D then
                                            exit;

                                        ldteOrderDate := lrecSalesInvHeader."Shipment Date";
                                    end;
                            end;
                        end;

                        //<ENRE1.00> - deleted code
                    end else begin
                        if Format(lfrfDocType.Value) = '5' then begin //Return Order
                                                                      //<ENRE1.00>
                            lblnIsReturnOrder := true;
                            //</ENRE1.00>

                            //<ENRE1.00>
                            lfrfFieldRef := prrfLine.Field(14228851);  //ENRE1.00
                            if Format(lfrfFieldRef.Value) = '' then begin
                                exit;
                            end;
                            //</ENRE1.00>
                        end else begin
                            //<ENRE1.00>
                            lfrfFieldRef := prrfLine.Field(5);
                            lfrfFieldRef2 := prrfLine.Field(14228851); //ENRE1.00

                            if (Format(lfrfFieldRef.Value) <> '2') and
                               (Format(lfrfFieldRef2.Value) = '') then begin
                                exit;
                            end;
                            //</ENRE1.00>
                        end;
                        //<ENRE1.00> - deleted code

                        //<ENRE1.00>
                        case grecSalesSetup."Rebate Date Source ELA" of
                            grecSalesSetup."Rebate Date Source ELA"::"Order Date":
                                begin
                                    //<ENRE1.00>
                                    ldteOrderDate := lrecSalesHeader."Order Date";
                                    //</ENRE1.00>
                                end;
                            grecSalesSetup."Rebate Date Source ELA"::"Shipment Date":
                                begin
                                    //<ENRE1.00>
                                    ldteOrderDate := lrecSalesHeader."Shipment Date";
                                    //</ENRE1.00>
                                end;
                        end;
                        //</ENRE1.00>
                    end;
                end;
            113:
                begin             //Sales Invoice Line
                    lfrfRefItemNo := prrfLine.Field(14228851); //ENRE1.00

                    //-- do not calculate if not an item AND the Ref. Item No. is blank
                    //<ENRE1.00>
                    lfrfFieldRef := prrfLine.Field(5);
                    lfrfFieldRef2 := prrfLine.Field(14228851);  //ENRE1.00
                    if (Format(lfrfFieldRef.Value) <> '2') and
                       (Format(lfrfFieldRef2.Value) = '') then begin
                        exit;
                    end;
                    //</ENRE1.00>

                    lfrfDocNo := prrfLine.Field(3);

                    if not lrecSalesInvHeader.Get(lfrfDocNo.Value) then begin
                        exit;
                    end;

                    //<ENRE1.00>
                    lcodShiptoCode := lrecSalesInvHeader."Ship-to Code";
                    lcodSalesperson := lrecSalesInvHeader."Salesperson Code";
                    //</ENRE1.00>

                    //<ENRE1.00> - deleted code

                    //<ENRE1.00>
                    case grecSalesSetup."Rebate Date Source ELA" of
                        grecSalesSetup."Rebate Date Source ELA"::"Order Date":
                            begin
                                //<ENRE1.00>
                                ldteOrderDate := lrecSalesInvHeader."Order Date";
                                //</ENRE1.00>
                            end;
                        grecSalesSetup."Rebate Date Source ELA"::"Shipment Date":
                            begin
                                //<ENRE1.00>
                                ldteOrderDate := lrecSalesInvHeader."Shipment Date";
                                //<ENRE1.00>
                            end;
                    end;
                    //</ENRE1.00>
                end;
            115:
                begin             //Sales Cr. Memo Line
                    lfrfDocNo := prrfLine.Field(3);

                    if not lrecSalesCrMemoHdr.Get(lfrfDocNo.Value) then begin
                        exit;
                    end else begin
                        //<ENRE1.00>
                        lcodShiptoCode := lrecSalesCrMemoHdr."Ship-to Code";
                        lcodSalesperson := lrecSalesCrMemoHdr."Salesperson Code";
                        //</ENRE1.00>

                        if lrecSalesCrMemoHdr."Return Order No." <> '' then begin
                            lrecReturnReceiptHdr.Reset;

                            lrecReturnReceiptHdr.SetRange("Return Order No.", lrecSalesCrMemoHdr."Return Order No.");

                            if lrecReturnReceiptHdr.FindFirst then begin
                                //<ENRE1.00>
                                case grecSalesSetup."Rebate Date Source ELA" of
                                    grecSalesSetup."Rebate Date Source ELA"::"Order Date":
                                        begin
                                            ldteOrderDate := lrecReturnReceiptHdr."Order Date";
                                        end;
                                    grecSalesSetup."Rebate Date Source ELA"::"Shipment Date":
                                        begin
                                            ldteOrderDate := lrecReturnReceiptHdr."Shipment Date";
                                        end;
                                end;
                                //</ENRE1.00>
                            end;
                        end else begin
                            //-- If not from a return order, use the Order Date field if not blank
                            if lrecSalesCrMemoHdr."Applies-to Doc. No." = '' then begin
                                //<ENRE1.00>
                                case grecSalesSetup."Rebate Date Source ELA" of
                                    grecSalesSetup."Rebate Date Source ELA"::"Order Date":
                                        begin
                                            //<ENRE1.00>
                                            if lrecSalesCrMemoHdr."Posting Date" = 0D then
                                                exit;

                                            ldteOrderDate := lrecSalesCrMemoHdr."Posting Date";
                                            //</ENRE1.00>
                                        end;
                                    grecSalesSetup."Rebate Date Source ELA"::"Shipment Date":
                                        begin
                                            if lrecSalesCrMemoHdr."Shipment Date" = 0D then
                                                exit;

                                            ldteOrderDate := lrecSalesCrMemoHdr."Shipment Date";
                                        end;
                                end;
                                //</ENRE1.00>
                            end else begin
                                if not lrecSalesInvHeader.Get(lrecSalesCrMemoHdr."Applies-to Doc. No.") then
                                    exit;

                                //<ENRE1.00>
                                case grecSalesSetup."Rebate Date Source ELA" of
                                    grecSalesSetup."Rebate Date Source ELA"::"Order Date":
                                        begin
                                            if lrecSalesInvHeader."Order Date" = 0D then
                                                exit;

                                            ldteOrderDate := lrecSalesInvHeader."Order Date";
                                        end;
                                    grecSalesSetup."Rebate Date Source ELA"::"Shipment Date":
                                        begin
                                            if lrecSalesInvHeader."Shipment Date" = 0D then
                                                exit;

                                            ldteOrderDate := lrecSalesInvHeader."Shipment Date";
                                        end;
                                end;
                                //</ENRE1.00>
                            end;
                        end;
                    end;

                    //<ENRE1.00> - deleted code
                end;
        end;

        //-- if a sales return, if unit price = 0 we exit
        //<ENRE1.00>
        if lblnIsReturnOrder then begin
            //<ENRE1.00>
            lfrfFieldRef := prrfLine.Field(22);

            if Format(lfrfFieldRef.Value) = '0' then
                exit;
            //</ENRE1.00>
        end;
        //</ENRE1.00>

        //<ENRE1.00>
        lfrfFieldRef := prrfLine.Field(2);
        if not lrecCustomer.Get(Format(lfrfFieldRef.Value)) then
            exit;

        lfrfFieldRef := prrfLine.Field(14228851); //ENRE1.00
        if Format(lfrfFieldRef.Value) <> '' then begin
            if not lrecItem.Get(Format(lfrfFieldRef.Value)) then
                exit;
        end else begin
            lfrfFieldRef := prrfLine.Field(6);

            if not lrecItem.Get(Format(lfrfFieldRef.Value)) then
                exit;
        end;
        //</ENRE1.00>

        lrecGLSetup.Get;

        //<ENRE1.00> - deleted code


        //<ENRE1.00>
        gdteOrderDate := ldteOrderDate;
        //</ENRE1.00>

        grecSalesSetup.Get;

        lrecTempRebate.Reset;
        lrecTempRebate.DeleteAll;

        lrecRebate.Reset;

        if grecSalesSetup."Use RbtHdr AppliesTo Filt ELA" then begin
            //-- If the Periodic Calc routine has been run with filters, we need to use them in this calculation
            lrecRebate.CopyFilters(grecRebateHeaderFilter);

            lrecRebate.SetRange("Apply-To Customer Type");
            lrecRebate.SetRange("Apply-To Customer No.");
            lrecRebate.SetRange("Apply-To Customer Ship-To Code");
            lrecRebate.SetRange("Apply-To Cust. Group Type");
            lrecRebate.SetRange("Apply-To Cust. Group Code");

            lrecRebate.SetFilter("Start Date", '%1|<=%2', 0D, ldteOrderDate);
            lrecRebate.SetFilter("End Date", '%1|>=%2', 0D, ldteOrderDate);

            //-- Get rebates applicable to ALL customers
            lrecRebate.SetRange("Apply-To Customer Type", lrecRebate."Apply-To Customer Type"::All);

            if lrecRebate.FindSet then begin
                repeat
                    lrecTempRebate.Init;
                    lrecTempRebate.TransferFields(lrecRebate);
                    if lrecTempRebate.Insert then;
                until lrecRebate.Next = 0;
            end;

            //-- Get Customer Specific rebates
            lrecRebate.SetRange("Apply-To Customer Type", lrecRebate."Apply-To Customer Type"::Specific);
            lrecRebate.SetRange("Apply-To Customer No.", lrecCustomer."No.");
            lrecRebate.SetFilter("Apply-To Customer Ship-To Code", '%1|%2', '', lcodShiptoCode);

            if lrecRebate.FindSet then begin
                repeat
                    lrecTempRebate.Init;
                    lrecTempRebate.TransferFields(lrecRebate);
                    if lrecTempRebate.Insert then;
                until lrecRebate.Next = 0;
            end;

            //-- Get Customer Rebate Group rebates
            lrecRebate.SetRange("Apply-To Customer Type", lrecRebate."Apply-To Customer Type"::Group);
            lrecRebate.SetRange("Apply-To Customer No.");
            lrecRebate.SetRange("Apply-To Customer Ship-To Code");
            lrecRebate.SetRange("Apply-To Cust. Group Type", lrecRebate."Apply-To Cust. Group Type"::"Rebate Group");
            lrecRebate.SetFilter("Apply-To Cust. Group Code", '%1|%2', '', lrecCustomer."Rebate Group Code ELA");

            if lrecRebate.FindSet then begin
                repeat
                    lrecTempRebate.Init;
                    lrecTempRebate.TransferFields(lrecRebate);
                    if lrecTempRebate.Insert then;
                until lrecRebate.Next = 0;
            end;
        end else begin
            //-- If the Periodic Calc routine has been run with filters, we need to use them in this calculation
            lrecRebate.CopyFilters(grecRebateHeaderFilter);

            //-- Use calculated Start/End Date, no matter what filters the user may have supplied for the dates
            lrecRebate.SetFilter("Start Date", '%1|<=%2', 0D, ldteOrderDate);
            lrecRebate.SetFilter("End Date", '%1|>=%2', 0D, ldteOrderDate);

            if lrecRebate.FindSet then begin
                repeat
                    lrecTempRebate.Init;
                    lrecTempRebate.TransferFields(lrecRebate);
                    if lrecTempRebate.Insert then;
                until lrecRebate.Next = 0;
            end;
        end;

        //---------------------------------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------------------------------
        //---------------------DO NOT USE LRECREBATE PAST THIS POINT. USE ONLY THE LRECTEMPREBATE TABLE FOR PERFORMANCE!!!-----------
        //---------------------------------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------------------------------

        //-- Get rid of lump sum rebates
        lrecTempRebate.Reset;
        lrecTempRebate.SetRange("Rebate Type", lrecTempRebate."Rebate Type"::"Lump Sum");
        lrecTempRebate.DeleteAll;

        //-- Get rid of blocked rebates
        lrecTempRebate.Reset;
        lrecTempRebate.SetRange(Blocked, true);
        lrecTempRebate.DeleteAll;

        lrecTempRebate.Reset;

        if lrecTempRebate.IsEmpty then
            exit;

        //- Load up a temp table of all rebate lines to avoid multiple reads to the server later
        if lrecTempRebate.FindSet then begin
            repeat
                lrecRebateLine.SetRange("Rebate Code", lrecTempRebate.Code);

                if not lrecRebateLine.IsEmpty then begin
                    lrecRebateLine.FindSet;

                    repeat
                        lrecTempRebateLine.Init;
                        lrecTempRebateLine.TransferFields(lrecRebateLine);
                        lrecTempRebateLine.Insert;
                    until lrecRebateLine.Next = 0;
                end;
            until lrecTempRebate.Next = 0;
        end;

        //<ENRE1.00>
        rdOnAfterInsertTempRebateLines(lrecTempRebateLine, lrecTempRebate, ldteOrderDate);
        //</ENRE1.00>

        //---------------------------------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------------------------------
        //-----------------DO NOT USE LRECREBATELINE PAST THIS POINT. USE ONLY THE LRECTEMPREBATELIN TABLE FOR PERFORMANCE!!!--------
        //---------------------------------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------------------------------
        if lrecTempRebate.FindSet then begin
            repeat
                //-- reset variables
                lblnIsApplicableCustomer := false;
                lblnIsApplicableItem := false;
                lblnIsApplicableSalesperson := false;
                lblnIsApplicableEntity := false;
                lblnItemCategoryCode := false;
                lblnItemRebateGroup := false;

                //<ENRE1.00>
                lblnspecificitemsdefined := false;
                lblnItemExists := false;
                //<ENRE1.00/>

                ldecLineLevelRebateValue := 0;

                lrecTempRebateLine.Reset;
                lrecTempRebateLine.SetRange("Rebate Code", lrecTempRebate.Code);

                if not lrecTempRebateLine.IsEmpty then begin
                    //-- Customers
                    lrecTempRebateLine.Reset;
                    lrecTempRebateLine.SetRange("Rebate Code", lrecTempRebate.Code);
                    lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Customer);

                    if lrecTempRebateLine.IsEmpty then begin
                        //-- no customer records were defined, so all customers apply to this rebate
                        lblnIsApplicableCustomer := true;
                    end else begin
                        //-- check for specific customer no.
                        lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"No.");
                        lrecTempRebateLine.SetRange(Value, lrecCustomer."No.");

                        if not lrecTempRebateLine.IsEmpty then begin
                            lrecTempRebateLine.SetRange("Ship-To Address Code", lcodShiptoCode);

                            //Ship-To Address Code
                            if lrecTempRebateLine.FindFirst then begin
                                lblnIsApplicableCustomer := lrecTempRebateLine.Include;
                            end else begin
                                lrecTempRebateLine.SetFilter("Ship-To Address Code", '%1', '');

                                if lrecTempRebateLine.FindFirst then begin
                                    lblnIsApplicableCustomer := lrecTempRebateLine.Include;

                                    if lblnIsApplicableCustomer then
                                        ldecLineLevelRebateValue := lrecTempRebateLine."Rebate Value";
                                end else begin
                                    lblnIsApplicableCustomer := false;
                                end;
                            end;
                        end else begin
                            //-- look for customer group
                            lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"Sub-type");
                            lrecTempRebateLine.SetRange(Value, lrecCustomer."Rebate Group Code ELA");

                            if not lrecTempRebateLine.FindFirst then begin
                                lblnIsApplicableCustomer := false;
                            end else begin
                                lblnIsApplicableCustomer := lrecTempRebateLine.Include;

                                if lblnIsApplicableCustomer then
                                    ldecLineLevelRebateValue := lrecTempRebateLine."Rebate Value";
                            end;
                        end;
                    end;


                    //-- SALESPERSON
                    if lblnIsApplicableCustomer then begin
                        lrecTempRebateLine.Reset;
                        lrecTempRebateLine.SetRange("Rebate Code", lrecTempRebate.Code);
                        lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Salesperson);

                        if lrecTempRebateLine.IsEmpty then begin
                            //-- no records were defined, so all apply to this rebate
                            lblnIsApplicableSalesperson := true;
                        end else begin
                            //-- check for specific no.
                            lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"No.");
                            lrecTempRebateLine.SetRange(Value, lcodSalesperson);

                            if lrecTempRebateLine.FindFirst then begin
                                lblnIsApplicableSalesperson := lrecTempRebateLine.Include;
                            end else begin
                                //-- look for rebate group
                                lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"Sub-type");
                                lrecTempRebateLine.SetRange(Value, lrecSalesperson."Rebate Group Code ELA");

                                if not lrecTempRebateLine.FindFirst then begin
                                    lblnIsApplicableSalesperson := false;
                                end else begin
                                    lblnIsApplicableSalesperson := lrecTempRebateLine.Include;
                                end;
                            end;
                        end;
                    end;


                    //-- Dimension
                    if lblnIsApplicableCustomer and lblnIsApplicableSalesperson then begin
                        lrecTempRebateLine.Reset;
                        lrecTempRebateLine.SetRange("Rebate Code", lrecTempRebate.Code);
                        lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Dimension);

                        if lrecTempRebateLine.IsEmpty then begin
                            //-- no records were defined, so all apply to this rebate
                            lblnIsApplicableEntity := true;
                        end else begin
                            lrecTempDimSetEntry.Reset;
                            lrecTempDimSetEntry.DeleteAll;

                            lrecTempRebateLine.FindSet;

                            //<ENRE1.00>
                            lcodDimValueCodeToUse := '';

                            case lintTableNo of
                                DATABASE::"Sales Line":
                                    begin
                                        lrecSalesLine.Get(lrecSalesHeader."Document Type", lrecSalesHeader."No.", lintLineNo);

                                        DimMgt.GetDimensionSet(lrecTempDimSetEntry, lrecSalesLine."Dimension Set ID");

                                        if lrecTempDimSetEntry.Get(lrecSalesLine."Dimension Set ID", lrecTempRebateLine."Dimension Code") then
                                            lcodDimValueCodeToUse := lrecTempDimSetEntry."Dimension Value Code";
                                    end;
                                DATABASE::"Sales Invoice Line":
                                    begin
                                        lrecSalesInvLine.Get(lrecSalesInvHeader."No.", lintLineNo);

                                        DimMgt.GetDimensionSet(lrecTempDimSetEntry, lrecSalesInvLine."Dimension Set ID");

                                        if lrecTempDimSetEntry.Get(lrecSalesInvLine."Dimension Set ID", lrecTempRebateLine."Dimension Code") then
                                            lcodDimValueCodeToUse := lrecTempDimSetEntry."Dimension Value Code";
                                    end;
                                DATABASE::"Sales Cr.Memo Line":
                                    begin
                                        lrecSalesCrMemoLine.Get(lrecSalesCrMemoHdr."No.", lintLineNo);

                                        DimMgt.GetDimensionSet(lrecTempDimSetEntry, lrecSalesCrMemoLine."Dimension Set ID");

                                        if lrecTempDimSetEntry.Get(lrecSalesCrMemoLine."Dimension Set ID", lrecTempRebateLine."Dimension Code") then
                                            lcodDimValueCodeToUse := lrecTempDimSetEntry."Dimension Value Code";
                                    end;
                            end;

                            if lcodDimValueCodeToUse <> '' then begin
                                lrecTempRebateLine.SetRange(Value, lcodDimValueCodeToUse);

                                if lrecTempRebateLine.FindFirst then
                                    lblnIsApplicableEntity := lrecTempRebateLine.Include
                                else
                                    lblnIsApplicableEntity := false;
                            end else begin
                                lblnIsApplicableEntity := false;
                            end;
                            //</ENRE1.00>
                        end;
                    end;

                    //-- ITEM
                    if lblnIsApplicableCustomer and lblnIsApplicableSalesperson and lblnIsApplicableEntity then begin
                        lrecTempRebateLine.Reset;
                        lrecTempRebateLine.SetRange("Rebate Code", lrecTempRebate.Code);
                        lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);

                        if lrecTempRebateLine.IsEmpty then begin
                            //-- no records defined so all apply to the rebate
                            lblnIsApplicableItem := true;
                            lblnspecificitemsdefined := true;
                            lblnItemRebateGroup := true;
                            lblnItemCategoryCode := true;
                        end else begin
                            lblnItemRebateGroup := true;
                            lblnItemCategoryCode := true;

                            //-- look for no.
                            lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"No.");

                            if not lrecTempRebateLine.IsEmpty then begin
                                lblnspecificitemsdefined := true;

                                //-- check for exact item no.
                                lrecTempRebateLine.SetRange(Value, lrecItem."No.");

                                if lrecTempRebateLine.FindFirst then begin
                                    lblnItemExists := true;

                                    lblnIsApplicableItem := lrecTempRebateLine.Include;

                                    if lblnIsApplicableItem and (lrecTempRebateLine."Rebate Value" <> 0) then
                                        ldecLineLevelRebateValue := lrecTempRebateLine."Rebate Value";
                                end else begin
                                    lblnItemExists := false;
                                end;
                            end else begin
                                lblnspecificitemsdefined := false;
                            end;

                            //-- no specific item nos. were defined, so we need to check group individually
                            if (not lblnspecificitemsdefined) or ((lblnspecificitemsdefined) and (not lblnItemExists)) then begin
                                lrecTempRebateLine.Reset;

                                lrecTempRebateLine.SetCurrentKey(Source, Type, "Sub-Type");

                                lrecTempRebateLine.SetRange("Rebate Code", lrecTempRebate.Code);
                                lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);
                                lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"Sub-type");

                                if not lrecTempRebateLine.FindSet then begin
                                    if not lblnspecificitemsdefined then begin
                                        lblnIsApplicableItem := true;
                                    end;
                                end else begin
                                    lrecRebateDetailTEMP.Reset;
                                    lrecRebateDetailTEMP.DeleteAll;

                                    repeat
                                        case lrecTempRebateLine."Sub-Type" of
                                            lrecTempRebateLine."Sub-Type"::"Rebate Group":
                                                begin
                                                    if lrecTempRebateLine.Value = lrecItem."Rebate Group Code ELA" then begin
                                                        lblnItemRebateGroup := lrecTempRebateLine.Include;

                                                        if lblnItemRebateGroup and (lrecTempRebateLine."Rebate Value" <> 0) then
                                                            ldecLineLevelRebateValue := lrecTempRebateLine."Rebate Value";
                                                    end else begin
                                                        //<ENRE1.00>
                                                        lblnItemRebateGroup := false;
                                                        //</ENRE1.00>
                                                    end;
                                                end;
                                            lrecTempRebateLine."Sub-Type"::"Category Code":
                                                begin
                                                    if lrecTempRebateLine.Value = lrecItem."Item Category Code" then begin
                                                        lblnItemCategoryCode := lrecTempRebateLine.Include;

                                                        if lblnItemCategoryCode and (lrecTempRebateLine."Rebate Value" <> 0) then
                                                            ldecLineLevelRebateValue := lrecTempRebateLine."Rebate Value";
                                                    end else begin
                                                        //<ENRE1.00>
                                                        lblnItemCategoryCode := false;
                                                        //</ENRE1.00>
                                                    end;
                                                end;
                                        end;
                                        lrecRebateDetailTEMP := lrecTempRebateLine;
                                    until lrecTempRebateLine.Next = 0;

                                    //-- If we satisfy all groups then we can mark the item as applicable to the rebate
                                    if (lblnItemRebateGroup) and (lblnItemCategoryCode) then
                                        lblnIsApplicableItem := true;
                                end;
                            end;
                        end;
                    end;


                    //-- Calculate rebate amount (if applicable)
                    if lblnspecificitemsdefined then begin
                        if (lblnItemExists and lblnIsApplicableItem) then begin
                            if lblnIsApplicableCustomer and lblnIsApplicableItem and
                               lblnIsApplicableSalesperson and lblnIsApplicableEntity then begin
                                CalcRebateFromRebateCode(lrecTempRebate.Code, prrfLine, pblnPeriodicCalc,
                                                            ldecLineLevelRebateValue, lrecItem."No.", precTempRebateEntry);
                            end;
                        end else
                            if (not lblnItemExists) then begin
                                if (lblnIsApplicableCustomer and lblnIsApplicableSalesperson and lblnIsApplicableEntity
                                  and lblnItemRebateGroup and lblnItemCategoryCode and lblnIsApplicableItem)
                                then begin
                                    CalcRebateFromRebateCode(lrecTempRebate.Code, prrfLine, pblnPeriodicCalc,
                                                                ldecLineLevelRebateValue, lrecItem."No.", precTempRebateEntry);
                                end;
                            end;
                    end else
                        if (lblnIsApplicableCustomer and lblnIsApplicableSalesperson and lblnIsApplicableEntity
                 and lblnItemRebateGroup and lblnItemCategoryCode)
               then begin
                            CalcRebateFromRebateCode(lrecTempRebate.Code, prrfLine, pblnPeriodicCalc,
                                                        ldecLineLevelRebateValue, lrecItem."No.", precTempRebateEntry);
                        end;
                end;
            until lrecTempRebate.Next = 0;
        end;
    end;


    procedure CalcRebateFromRebateCode(pcodRebate: Code[20]; prrfLine: RecordRef; pblnPeriodocCalc: Boolean; pdecRebateValue: Decimal; pcodItemNo: Code[20]; var precTempRebateEntry: Record "Rebate Entry ELA")
    var
        lrecRebateSetup: Record "Rebate Header ELA";
        lrecGLSetup: Record "General Ledger Setup";
        lintTableNo: Integer;
        ldecRebateAmtLCY: Decimal;
        ldecRebateAmtRBT: Decimal;
        ldecRebateAmtDOC: Decimal;
        lfrfDocType: FieldRef;
        lfrfDocNo: FieldRef;
        lfrfLineNo: FieldRef;
        lfrfQuantity: FieldRef;
        lfrfUOM: FieldRef;
        lfrfUnitPrice: FieldRef;
        lfrfNo: FieldRef;
        lfrfLineDiscountAmt: FieldRef;
        lfrfInvDiscountAmt: FieldRef;
        ldtePostingDate: Date;
        ldecCurrencyFactor: Decimal;
        ltxtFilter: Text[1024];
        lcodCurrencyCode: Code[10];
        ldecLineQuantity: Decimal;
        ldecUnitPrice: Decimal;
        lrecItem: Record Item;
        lcduUOMMgt: Codeunit "Unit of Measure Management";
        ldecRebateQtyPerUOM: Decimal;
        ldecLineQtyPerUOM: Decimal;
        lrecSalesHeader: Record "Sales Header";
        lrecSalesInvoiceHdr: Record "Sales Invoice Header";
        lrecSalesCrMemoHdr: Record "Sales Cr.Memo Header";
        lrecExchRate: Record "Currency Exchange Rate";
        lrecRebateEntry: Record "Rebate Entry ELA";
        lrecSalesLine: Record "Sales Line";
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
        ldecLineDiscountAmt: Decimal;
        ldecInvDiscountAmt: Decimal;
        ldecLineAmount: Decimal;
        lfrfFieldRef: FieldRef;
        lrecCustomer: Record Customer;
        lrecItemBOCHeader: Record "Item BOC Header ELA";
        lrecItemBOCLine: Record "Item BOC Line ELA";
        lrecCommAllLine: Record "Commodity Allocation Line ELA";
        lrecQtySold: Decimal;
        ldecRebateUOMQtySold: Decimal;
        lintEntryNo: Integer;
        lblnVariableWeight: Boolean;
        lcduVariableWeightManagement: Codeunit "Rebate Sales Functions ELA";
        lrecInvSetup: Record "Inventory Setup";
        lblnReplaced: Boolean;
        lrecItemBOCLine2: Record "Item BOC Line ELA";
        lrecCommodityEntry: Record "Commodity Entry ELA";
        ldecOpenCommQty: Decimal;
        ldecQtyUsed: Decimal;
        ldecPartial: Decimal;
        lrecCommAllLine2: Record "Commodity Allocation Line ELA";
        ldecOpenCommQty2: Decimal;
        ldecQtyUsed2: Decimal;
        ldecCurrentDocQty: Decimal;
        ldecCurrentDocQty2: Decimal;
        ldecAvg: Decimal;
        lrecManf: Record Manufacturer;
        lrecLineWeightStats: Record "Line Weight Statistics ELA";
        ldecWeight: Decimal;
        lctxtInvalidSalesLineTable: Label 'Invalid Sales Line table.';
        ldecQtyBase: Decimal;
        lrecRebateUnitOfMeasure: Record "Unit of Measure";
    begin
        if not lrecRebateSetup.Get(pcodRebate) then
            exit;

        //<ENRE1.00>
        if lrecRebateSetup.Blocked then
            exit;
        //</ENRE1.00>

        //<ENRE1.00>
        grecCommodityLedgerTemp.Reset;
        grecCommodityLedgerTemp.DeleteAll;
        //</ENRE1.00>

        //-- Rebate Value will be passed in if it is found at a rebate card LINE level, otherwise we use the header level value
        if pdecRebateValue = 0 then
            pdecRebateValue := lrecRebateSetup."Rebate Value";

        lintTableNo := prrfLine.Number;

        case lintTableNo of
            37:
                begin
                    lfrfDocType := prrfLine.Field(1);
                    lfrfDocNo := prrfLine.Field(3);
                    lfrfLineNo := prrfLine.Field(4);

                    //-- Get Sales Header
                    if not lrecSalesHeader.Get(lfrfDocType.Value, lfrfDocNo.Value) then
                        exit;

                    //-- Get Sales Line
                    if not lrecSalesLine.Get(lfrfDocType.Value, lfrfDocNo.Value, lfrfLineNo.Value) then
                        exit;

                    //<ENRE1.00>
                    ldtePostingDate := lrecSalesHeader."Posting Date";
                    ldecCurrencyFactor := lrecSalesHeader."Currency Factor";
                    lcodCurrencyCode := lrecSalesHeader."Currency Code";
                    //</ENRE1.00>
                end;
            113:
                begin
                    lfrfDocNo := prrfLine.Field(3);
                    lfrfLineNo := prrfLine.Field(4);

                    //-- Get invoice header
                    if not lrecSalesInvoiceHdr.Get(lfrfDocNo.Value) then
                        exit;

                    //-- Get Invoice Line
                    if not lrecSalesInvLine.Get(lfrfDocNo.Value, lfrfLineNo.Value) then
                        exit;

                    //<ENRE1.00>
                    ldtePostingDate := lrecSalesInvoiceHdr."Posting Date";
                    ldecCurrencyFactor := lrecSalesInvoiceHdr."Currency Factor";
                    lcodCurrencyCode := lrecSalesInvoiceHdr."Currency Code";
                    //</ENRE1.00>
                end;
            115:
                begin
                    lfrfDocNo := prrfLine.Field(3);
                    lfrfLineNo := prrfLine.Field(4);

                    //-- Get credit header
                    if not lrecSalesCrMemoHdr.Get(lfrfDocNo.Value) then
                        exit;

                    //-- Get credit Line
                    if not lrecSalesCrMemoLine.Get(lfrfDocNo.Value, lfrfLineNo.Value) then
                        exit;

                    //<ENRE1.00>
                    ldtePostingDate := lrecSalesCrMemoHdr."Posting Date";
                    ldecCurrencyFactor := lrecSalesCrMemoHdr."Currency Factor";
                    lcodCurrencyCode := lrecSalesCrMemoHdr."Currency Code";
                    //</ENRE1.00>
                end;
        end;



        //<ENRE1.00>
        if lrecRebateSetup."Rebate Type" = lrecRebateSetup."Rebate Type"::Commodity then begin
            pdecRebateValue := 0;
            grecCommodityLedgerTemp.Reset;
            grecCommodityLedgerTemp.DeleteAll;

            //<ENRE1.00>
            Clear(lblnReplaced);
            //</ENRE1.00>

            lblnVariableWeight := lcduVariableWeightManagement.IsCatchWeightItem(pcodItemNo, false);

            case lintTableNo of
                37:
                    begin
                        lrecCustomer.Get(lrecSalesHeader."Sell-to Customer No.");
                        if lrecCustomer."Recipient Agency No. ELA" = '' then begin
                            exit;
                        end;
                    end;
                113:
                    begin
                        lrecCustomer.Get(lrecSalesInvoiceHdr."Sell-to Customer No.");
                        if lrecCustomer."Recipient Agency No. ELA" = '' then begin
                            exit;
                        end;
                    end;
                115:
                    begin
                        lrecCustomer.Get(lrecSalesCrMemoHdr."Sell-to Customer No.");
                        if lrecCustomer."Recipient Agency No. ELA" = '' then begin
                            exit;
                        end;
                    end;
            end;


            lrecItemBOCHeader.SetRange("Item No.", pcodItemNo);

            if lblnVariableWeight then begin
                lrecInvSetup.Get;
                lrecInvSetup.TestField("Standard Weight UOM ELA");
                lrecItemBOCHeader.SetRange("Unit of Measure Code", lrecInvSetup."Standard Weight UOM ELA");
            end else begin
                case lintTableNo of
                    37:
                        begin
                            lrecItemBOCHeader.SetRange("Unit of Measure Code", lrecSalesLine."Unit of Measure Code");
                        end;
                    113:
                        begin
                            lrecItemBOCHeader.SetRange("Unit of Measure Code", lrecSalesInvLine."Unit of Measure Code");
                        end;
                    115:
                        begin
                            lrecItemBOCHeader.SetRange("Unit of Measure Code", lrecSalesCrMemoLine."Unit of Measure Code");
                        end;
                end;
            end;

            lrecItemBOCHeader.SetFilter("Starting Date", '%1|<=%2', 0D, gdteOrderDate);
            lrecItemBOCHeader.SetFilter("Ending Date", '%1|>=%2', 0D, gdteOrderDate);
            lrecItemBOCHeader.SetRange(Status, lrecItemBOCHeader.Status::Certified);
            if not lrecItemBOCHeader.FindFirst then begin
                exit;
            end;

            lrecItemBOCLine.SetRange("Item BOC No.", lrecItemBOCHeader."No.");
            if lrecItemBOCLine.FindSet then begin

                case lintTableNo of
                    37:
                        begin
                            if lblnVariableWeight then begin
                                //<ENRE1.00>
                                Clear(lrecLineWeightStats);
                                lcduVariableWeightManagement.CalcLineWeightStats(prrfLine, lrecLineWeightStats, 0);
                                lrecQtySold := lrecLineWeightStats."Total Net Weight";
                                //</ENRE1.00>
                            end else begin
                                lrecQtySold := lrecSalesLine.Quantity;
                            end;
                        end;
                    113:
                        begin
                            if lblnVariableWeight then begin
                                //<ENRE1.00>
                                lrecQtySold := lrecSalesInvLine."Line Net Weight ELA";
                                //</ENRE1.00>
                            end else begin
                                lrecQtySold := lrecSalesInvLine.Quantity;
                            end;
                        end;
                    115:
                        begin
                            if lblnVariableWeight then begin
                                //<ENRE1.00>
                                lrecQtySold := lrecSalesCrMemoLine."Line Net Weight ELA";
                                //</ENRE1.00>
                            end else begin
                                lrecQtySold := lrecSalesCrMemoLine.Quantity;
                            end;
                        end;
                end;

                repeat

                    //<ENRE1.00>
                    lrecItem.Get(pcodItemNo);
                    if lrecItem."Manufacturer Code" <> '' then begin
                        lrecManf.Get(lrecItem."Manufacturer Code");
                        if lrecManf."Vendor No. ELA" <> '' then begin
                            //</ENRE1.00>

                            lrecCommAllLine.Reset;
                            lrecCommAllLine.SetRange("Recipient Agency No.", lrecCustomer."Recipient Agency No. ELA");
                            //<ENRE1.00> - deleted code
                            lrecCommAllLine.SetRange("Vendor No.", lrecManf."Vendor No. ELA");
                            lrecCommAllLine.SetRange("Commodity No.", lrecItemBOCLine."Commodity No.");
                            lrecCommAllLine.SetFilter("Starting Date", '%1|<=%2', 0D, gdteOrderDate);
                            lrecCommAllLine.SetFilter("Ending Date", '%1|>=%2', 0D, gdteOrderDate);

                            if lrecCommAllLine.FindLast then begin
                                lrecCommAllLine.CalcFields("Quantity Used");

                                if (lintTableNo = 113) or ((lintTableNo = 37) and (lrecSalesLine."Document Type" in
                                                                [lrecSalesLine."Document Type"::Quote, lrecSalesLine."Document Type"::Order,
                                                                lrecSalesLine."Document Type"::Invoice])) then begin

                                    //<ENRE1.00>
                                    if lrecSalesInvoiceHdr."Order No." <> '' then begin
                                        ldecCurrentDocQty := CalcCurrentDocCommodityUsed(lrecCommAllLine, lintTableNo, lrecSalesLine."Document Type"::
                        Order,
                                                          lrecSalesInvoiceHdr."Order No.", lrecSalesInvLine."Line No.");
                                    end else begin
                                        ldecCurrentDocQty := CalcCurrentDocCommodityUsed(lrecCommAllLine, lintTableNo,
                                                          lrecSalesLine."Document Type"::Invoice,
                                                          lrecSalesInvoiceHdr."Pre-Assigned No.", lrecSalesInvLine."Line No.");
                                    end;
                                    //</ENRE1.00>

                                    //<ENRE1.00>
                                    if grecSalesSetup."Inc Open Ord CommodityCalc ELA" then begin
                                        if lrecSalesInvoiceHdr."Order No." <> '' then begin
                                            ldecOpenCommQty := CalcOpenCommodityUsed(lrecCommAllLine, lintTableNo, lrecSalesLine."Document Type"::Order,
                                                              lrecSalesInvoiceHdr."Order No.", lrecSalesInvLine."Line No.");
                                        end else begin
                                            ldecOpenCommQty := CalcOpenCommodityUsed(lrecCommAllLine, lintTableNo, lrecSalesLine."Document Type"::Invoice,
                                                              lrecSalesInvoiceHdr."Pre-Assigned No.", lrecSalesInvLine."Line No.");
                                        end;
                                    end else begin
                                        ldecOpenCommQty := 0;
                                    end;

                                    ldecQtyUsed := lrecCommAllLine."Quantity Used" + ldecOpenCommQty + ldecCurrentDocQty;
                                    //</ENRE1.00>

                                    if (lrecItemBOCLine."Quantity per" * lrecQtySold) <=
                                       (lrecCommAllLine.Quantity - ldecQtyUsed) then begin

                                        lintEntryNo := lintEntryNo + 10000;
                                        grecCommodityLedgerTemp."Entry No." := lintEntryNo;
                                        grecCommodityLedgerTemp."Posting Date" := gdteOrderDate;
                                        grecCommodityLedgerTemp."Commodity No." := lrecCommAllLine."Commodity No.";
                                        grecCommodityLedgerTemp."Vendor No." := lrecCommAllLine."Vendor No.";
                                        grecCommodityLedgerTemp."Recipient Agency No." := lrecCommAllLine."Recipient Agency No.";
                                        grecCommodityLedgerTemp."Rebate Ledger Entry No." := 0;

                                        grecCommodityLedgerTemp.Quantity := lrecItemBOCLine."Quantity per" * lrecQtySold;
                                        grecCommodityLedgerTemp."Amount (LCY)" := lrecItemBOCLine."Unit Amount" * lrecItemBOCLine."Quantity per" *
                        lrecQtySold;

                                        //<ENRE1.00>
                                        if lrecSalesInvoiceHdr."Order No." <> '' then begin
                                            grecCommodityLedgerTemp."Source Type" := grecCommodityLedgerTemp."Source Type"::Order;
                                            grecCommodityLedgerTemp."Source No." := lrecSalesInvoiceHdr."Order No.";
                                            grecCommodityLedgerTemp."Source Line No." := lrecSalesInvLine."Line No.";
                                        end else begin
                                            grecCommodityLedgerTemp."Source Type" := grecCommodityLedgerTemp."Source Type"::Invoice;
                                            grecCommodityLedgerTemp."Source No." := lrecSalesInvoiceHdr."Pre-Assigned No.";
                                            grecCommodityLedgerTemp."Source Line No." := lrecSalesInvLine."Line No.";
                                        end;
                                        //</ENRE1.00>

                                        grecCommodityLedgerTemp.Insert;
                                        pdecRebateValue := pdecRebateValue + (lrecItemBOCLine."Unit Amount" * lrecItemBOCLine."Quantity per" * lrecQtySold)
                        ;
                                    end else begin

                                        //<ENRE1.00>
                                        lblnReplaced := false;

                                        //<ENRE1.00>
                                        lrecItem.Get(pcodItemNo);
                                        if lrecItem."Manufacturer Code" <> '' then begin
                                            lrecManf.Get(lrecItem."Manufacturer Code");
                                            if lrecManf."Vendor No. ELA" <> '' then begin
                                                //</ENRE1.00>
                                                if lrecItemBOCLine."Replacement Commodity No." <> '' then begin
                                                    lrecCommAllLine2.Reset;
                                                    lrecCommAllLine2.SetRange("Recipient Agency No.", lrecCustomer."Recipient Agency No. ELA");
                                                    //<ENRE1.00>
                                                    lrecItem.Get(pcodItemNo);
                                                    //</ENRE1.00>
                                                    lrecCommAllLine2.SetRange("Vendor No.", lrecManf."Vendor No. ELA");
                                                    lrecCommAllLine2.SetRange("Commodity No.", lrecItemBOCLine."Replacement Commodity No.");
                                                    lrecCommAllLine2.SetFilter("Starting Date", '%1|<=%2', 0D, gdteOrderDate);
                                                    lrecCommAllLine2.SetFilter("Ending Date", '%1|>=%2', 0D, gdteOrderDate);

                                                    if lrecCommAllLine2.FindLast then begin
                                                        lrecCommAllLine2.CalcFields("Quantity Used");

                                                        if lrecSalesInvoiceHdr."Order No." <> '' then begin
                                                            ldecCurrentDocQty2 := CalcCurrentDocCommodityUsed(lrecCommAllLine2, lintTableNo,
                                                                                        lrecSalesLine."Document Type"::Order,
                                                                                        lrecSalesInvoiceHdr."Order No.", lrecSalesInvLine."Line No.");
                                                        end else begin
                                                            ldecCurrentDocQty2 := CalcCurrentDocCommodityUsed(lrecCommAllLine2, lintTableNo,
                                                                                        lrecSalesLine."Document Type"::Invoice,
                                                                                        lrecSalesInvoiceHdr."Pre-Assigned No.", lrecSalesInvLine."Line No.");
                                                        end;

                                                        //<ENRE1.00>
                                                        if grecSalesSetup."Inc Open Ord CommodityCalc ELA" then begin
                                                            if lrecSalesInvoiceHdr."Order No." <> '' then begin
                                                                ldecOpenCommQty2 := CalcOpenCommodityUsed(lrecCommAllLine2, lintTableNo,
                                                                                            lrecSalesLine."Document Type"::Order,
                                                                                            lrecSalesInvoiceHdr."Order No.", lrecSalesInvLine."Line No.");
                                                            end else begin
                                                                ldecOpenCommQty2 := CalcOpenCommodityUsed(lrecCommAllLine2, lintTableNo,
                                                                                            lrecSalesLine."Document Type"::Invoice,
                                                                                            lrecSalesInvoiceHdr."Pre-Assigned No.", lrecSalesInvLine."Line No.");
                                                            end;
                                                        end else begin
                                                            ldecOpenCommQty2 := 0;
                                                        end;

                                                        ldecQtyUsed2 := lrecCommAllLine2."Quantity Used" + ldecOpenCommQty2 + ldecCurrentDocQty2;
                                                        //</ENRE1.00>

                                                        if (lrecItemBOCLine."Replacement Quantity per" * lrecQtySold) <=
                                                           (lrecCommAllLine2.Quantity - ldecQtyUsed2) then begin

                                                            lintEntryNo := lintEntryNo + 10000;
                                                            grecCommodityLedgerTemp."Entry No." := lintEntryNo;
                                                            grecCommodityLedgerTemp."Posting Date" := gdteOrderDate;
                                                            grecCommodityLedgerTemp."Commodity No." := lrecCommAllLine2."Commodity No.";
                                                            grecCommodityLedgerTemp."Vendor No." := lrecCommAllLine."Vendor No.";
                                                            grecCommodityLedgerTemp."Recipient Agency No." := lrecCommAllLine2."Recipient Agency No.";
                                                            grecCommodityLedgerTemp."Rebate Ledger Entry No." := 0;
                                                            grecCommodityLedgerTemp.Quantity := (lrecItemBOCLine."Replacement Quantity per" * lrecQtySold);
                                                            grecCommodityLedgerTemp."Amount (LCY)" := lrecItemBOCLine."Replacement Unit Amount" *
                                                                                                    ((lrecItemBOCLine."Replacement Quantity per" * lrecQtySold));
                                                            //<ENRE1.00>
                                                            if lrecSalesInvoiceHdr."Order No." <> '' then begin
                                                                grecCommodityLedgerTemp."Source Type" := grecCommodityLedgerTemp."Source Type"::Order;
                                                                grecCommodityLedgerTemp."Source No." := lrecSalesInvoiceHdr."Order No.";
                                                                grecCommodityLedgerTemp."Source Line No." := lrecSalesInvLine."Line No.";
                                                            end else begin
                                                                grecCommodityLedgerTemp."Source Type" := grecCommodityLedgerTemp."Source Type"::Invoice;
                                                                grecCommodityLedgerTemp."Source No." := lrecSalesInvoiceHdr."Pre-Assigned No.";
                                                                grecCommodityLedgerTemp."Source Line No." := lrecSalesInvLine."Line No.";
                                                            end;
                                                            //</ENRE1.00>

                                                            grecCommodityLedgerTemp.Insert;
                                                            pdecRebateValue := pdecRebateValue + (lrecItemBOCLine."Replacement Unit Amount" *
                                                                                                  ((lrecItemBOCLine."Replacement Quantity per" * lrecQtySold)));
                                                            lblnReplaced := true;
                                                        end;
                                                    end;
                                                end;

                                                //<ENRE1.00>
                                            end;
                                        end;
                                        //</ENRE1.00>

                                        if not lblnReplaced then begin
                                            if lrecItemBOCHeader."Commodity Relationship" = lrecItemBOCHeader."Commodity Relationship"::Dependent then begin
                                                exit;
                                            end;

                                            //<ENRE1.00>
                                            if lblnVariableWeight then begin
                                                case lintTableNo of
                                                    37:
                                                        begin
                                                            ldecAvg := Round(lrecQtySold / lrecSalesLine.Quantity, 0.01);
                                                        end;
                                                    113:
                                                        begin
                                                            ldecAvg := Round(lrecQtySold / lrecSalesInvLine.Quantity, 0.01);
                                                        end;
                                                end;
                                            end else begin
                                                ldecAvg := 1;
                                            end;

                                            if (lrecCommAllLine.Quantity - ldecQtyUsed) >= (ldecAvg * lrecItemBOCLine."Quantity per") then begin
                                                ldecPartial := (lrecCommAllLine.Quantity - ldecQtyUsed) div (ldecAvg * lrecItemBOCLine."Quantity per");

                                                //</ENRE1.00>

                                                lintEntryNo := lintEntryNo + 10000;
                                                grecCommodityLedgerTemp."Entry No." := lintEntryNo;
                                                grecCommodityLedgerTemp."Posting Date" := gdteOrderDate;
                                                grecCommodityLedgerTemp."Commodity No." := lrecCommAllLine."Commodity No.";
                                                grecCommodityLedgerTemp."Vendor No." := lrecCommAllLine."Vendor No.";
                                                grecCommodityLedgerTemp."Recipient Agency No." := lrecCommAllLine."Recipient Agency No.";
                                                grecCommodityLedgerTemp."Rebate Ledger Entry No." := 0;
                                                grecCommodityLedgerTemp.Quantity := ldecPartial * lrecItemBOCLine."Quantity per" * ldecAvg;
                                                grecCommodityLedgerTemp."Amount (LCY)" := lrecItemBOCLine."Unit Amount" *
                                                                                         ldecPartial * lrecItemBOCLine."Quantity per" * ldecAvg;

                                                //<ENRE1.00>
                                                if lrecSalesInvoiceHdr."Order No." <> '' then begin
                                                    grecCommodityLedgerTemp."Source Type" := grecCommodityLedgerTemp."Source Type"::Order;
                                                    grecCommodityLedgerTemp."Source No." := lrecSalesInvoiceHdr."Order No.";
                                                    grecCommodityLedgerTemp."Source Line No." := lrecSalesInvLine."Line No.";
                                                end else begin
                                                    grecCommodityLedgerTemp."Source Type" := grecCommodityLedgerTemp."Source Type"::Invoice;
                                                    grecCommodityLedgerTemp."Source No." := lrecSalesInvoiceHdr."Pre-Assigned No.";
                                                    grecCommodityLedgerTemp."Source Line No." := lrecSalesInvLine."Line No.";
                                                end;
                                                //</ENRE1.00>

                                                grecCommodityLedgerTemp.Insert;
                                                pdecRebateValue := pdecRebateValue + (lrecItemBOCLine."Unit Amount" *
                                                                                       (ldecPartial) * lrecItemBOCLine."Quantity per" * ldecAvg);

                                            end;
                                        end;
                                        //</ENRE1.00>
                                    end;

                                end else begin
                                    //credits
                                    //<ENRE1.00>
                                    ldecOpenCommQty := 0;

                                    ldecCurrentDocQty := CalcCurrentDocCommodityUsed(lrecCommAllLine, lintTableNo,
                                                                lrecSalesLine."Document Type"::"Credit Memo",
                                                                lrecSalesCrMemoHdr."Pre-Assigned No.", lrecSalesCrMemoLine."Line No.");

                                    ldecQtyUsed := lrecCommAllLine."Quantity Used" + ldecCurrentDocQty;
                                    //</ENRE1.00>

                                    if (lrecItemBOCLine."Quantity per" * lrecQtySold) <=
                                       (ldecQtyUsed) then begin

                                        lintEntryNo := lintEntryNo + 10000;
                                        grecCommodityLedgerTemp."Entry No." := lintEntryNo;
                                        grecCommodityLedgerTemp."Posting Date" := gdteOrderDate;
                                        grecCommodityLedgerTemp."Commodity No." := lrecCommAllLine."Commodity No.";
                                        grecCommodityLedgerTemp."Vendor No." := lrecCommAllLine."Vendor No.";
                                        grecCommodityLedgerTemp."Recipient Agency No." := lrecCommAllLine."Recipient Agency No.";
                                        grecCommodityLedgerTemp."Rebate Ledger Entry No." := 0;

                                        grecCommodityLedgerTemp.Quantity := -(lrecItemBOCLine."Quantity per" * lrecQtySold);
                                        grecCommodityLedgerTemp."Amount (LCY)" := -(lrecItemBOCLine."Unit Amount"
                                                                                   * lrecItemBOCLine."Quantity per" * lrecQtySold);
                                        //<ENRE1.00>
                                        grecCommodityLedgerTemp."Source Type" := grecCommodityLedgerTemp."Source Type"::"Credit Memo";
                                        grecCommodityLedgerTemp."Source No." := lrecSalesCrMemoHdr."Pre-Assigned No.";
                                        grecCommodityLedgerTemp."Source Line No." := lrecSalesCrMemoLine."Line No.";
                                        //</ENRE1.00>

                                        grecCommodityLedgerTemp.Insert;
                                        pdecRebateValue := pdecRebateValue + (lrecItemBOCLine."Unit Amount" * lrecItemBOCLine."Quantity per" * lrecQtySold)
                        ;
                                    end else begin

                                        //<ENRE1.00>

                                        lblnReplaced := false;

                                        //<ENRE1.00>
                                        lrecItem.Get(pcodItemNo);
                                        if lrecItem."Manufacturer Code" <> '' then begin
                                            lrecManf.Get(lrecItem."Manufacturer Code");
                                            if lrecManf."Vendor No. ELA" <> '' then begin
                                                //</ENRE1.00>

                                                if lrecItemBOCLine."Replacement Commodity No." <> '' then begin
                                                    lrecCommAllLine2.Reset;
                                                    lrecCommAllLine2.SetRange("Recipient Agency No.", lrecCustomer."Recipient Agency No. ELA");
                                                    lrecItem.Get(pcodItemNo);
                                                    lrecCommAllLine2.SetRange("Vendor No.", lrecManf."Vendor No. ELA");
                                                    lrecCommAllLine2.SetRange("Commodity No.", lrecItemBOCLine."Replacement Commodity No.");
                                                    lrecCommAllLine2.SetFilter("Starting Date", '%1|<=%2', 0D, gdteOrderDate);
                                                    lrecCommAllLine2.SetFilter("Ending Date", '%1|>=%2', 0D, gdteOrderDate);

                                                    if lrecCommAllLine2.FindLast then begin
                                                        lrecCommAllLine2.CalcFields("Quantity Used");

                                                        ldecCurrentDocQty2 := CalcCurrentDocCommodityUsed(lrecCommAllLine2, lintTableNo,
                                                                                    lrecSalesLine."Document Type"::"Credit Memo",
                                                                                    lrecSalesCrMemoHdr."Pre-Assigned No.", lrecSalesCrMemoLine."Line No.");


                                                        //<ENRE1.00>

                                                        ldecQtyUsed2 := lrecCommAllLine2."Quantity Used" + ldecCurrentDocQty2;
                                                        //</ENRE1.00>

                                                        if (lrecItemBOCLine."Replacement Quantity per" * lrecQtySold) <=
                                                           (ldecQtyUsed2) then begin

                                                            lintEntryNo := lintEntryNo + 10000;
                                                            grecCommodityLedgerTemp."Entry No." := lintEntryNo;
                                                            grecCommodityLedgerTemp."Posting Date" := gdteOrderDate;
                                                            grecCommodityLedgerTemp."Commodity No." := lrecCommAllLine2."Commodity No.";
                                                            grecCommodityLedgerTemp."Vendor No." := lrecCommAllLine."Vendor No.";
                                                            grecCommodityLedgerTemp."Recipient Agency No." := lrecCommAllLine2."Recipient Agency No.";
                                                            grecCommodityLedgerTemp."Rebate Ledger Entry No." := 0;
                                                            grecCommodityLedgerTemp.Quantity := -(lrecItemBOCLine."Replacement Quantity per" * lrecQtySold);
                                                            grecCommodityLedgerTemp."Amount (LCY)" := -(lrecItemBOCLine."Replacement Unit Amount" *
                                                                                                    ((lrecItemBOCLine."Replacement Quantity per" * lrecQtySold)));
                                                            //<ENRE1.00>
                                                            grecCommodityLedgerTemp."Source Type" := grecCommodityLedgerTemp."Source Type"::"Credit Memo";
                                                            grecCommodityLedgerTemp."Source No." := lrecSalesCrMemoHdr."Pre-Assigned No.";
                                                            grecCommodityLedgerTemp."Source Line No." := lrecSalesCrMemoLine."Line No.";
                                                            //</ENRE1.00>

                                                            grecCommodityLedgerTemp.Insert;
                                                            pdecRebateValue := pdecRebateValue + (lrecItemBOCLine."Replacement Unit Amount" *
                                                                                                  ((lrecItemBOCLine."Replacement Quantity per" * lrecQtySold)));
                                                            lblnReplaced := true;
                                                        end;
                                                    end;
                                                end;

                                                //</ENRE1.00>

                                                //<ENRE1.00>
                                            end;
                                        end;
                                        //</ENRE1.00>
                                        if not lblnReplaced then begin
                                            if lrecItemBOCHeader."Commodity Relationship" = lrecItemBOCHeader."Commodity Relationship"::Dependent then begin
                                                exit;
                                            end;

                                            //<ENRE1.00>
                                            if lblnVariableWeight then begin
                                                case lintTableNo of
                                                    37:
                                                        begin
                                                            ldecAvg := Round(lrecQtySold / lrecSalesLine.Quantity, 0.01);
                                                        end;
                                                    115:
                                                        begin
                                                            ldecAvg := Round(lrecQtySold / lrecSalesCrMemoLine.Quantity, 0.01);
                                                        end;
                                                end;
                                            end else begin
                                                ldecAvg := 1;
                                            end;

                                            if ldecQtyUsed >= (lrecItemBOCLine."Quantity per" * ldecAvg) then begin

                                                ldecPartial := (ldecQtyUsed) div (lrecItemBOCLine."Quantity per" * ldecAvg);
                                                //</ENRE1.00>

                                                lintEntryNo := lintEntryNo + 10000;
                                                grecCommodityLedgerTemp."Entry No." := lintEntryNo;
                                                grecCommodityLedgerTemp."Posting Date" := gdteOrderDate;
                                                grecCommodityLedgerTemp."Commodity No." := lrecCommAllLine."Commodity No.";
                                                grecCommodityLedgerTemp."Vendor No." := lrecCommAllLine."Vendor No.";
                                                grecCommodityLedgerTemp."Recipient Agency No." := lrecCommAllLine."Recipient Agency No.";
                                                grecCommodityLedgerTemp."Rebate Ledger Entry No." := 0;

                                                grecCommodityLedgerTemp.Quantity := -(ldecPartial) * lrecItemBOCLine."Quantity per" * ldecAvg;
                                                grecCommodityLedgerTemp."Amount (LCY)" := -(lrecItemBOCLine."Unit Amount" * (ldecPartial) *
                                                                                           lrecItemBOCLine."Quantity per" * ldecAvg);

                                                //<ENRE1.00>
                                                grecCommodityLedgerTemp."Source Type" := grecCommodityLedgerTemp."Source Type"::"Credit Memo";
                                                grecCommodityLedgerTemp."Source No." := lrecSalesCrMemoHdr."Pre-Assigned No.";
                                                grecCommodityLedgerTemp."Source Line No." := lrecSalesCrMemoLine."Line No.";
                                                //</ENRE1.00>

                                                grecCommodityLedgerTemp.Insert;
                                                pdecRebateValue := pdecRebateValue + (lrecItemBOCLine."Unit Amount" * (ldecPartial) *
                                                                                       lrecItemBOCLine."Quantity per" * ldecAvg);
                                            end;
                                        end;
                                    end;
                                end;
                            end else begin
                                if lrecItemBOCHeader."Commodity Relationship" = lrecItemBOCHeader."Commodity Relationship"::Dependent then begin
                                    exit;
                                end;
                            end;
                            //<ENRE1.00>
                        end else begin
                            if lrecItemBOCHeader."Commodity Relationship" = lrecItemBOCHeader."Commodity Relationship"::Dependent then begin
                                exit;
                            end;
                        end;
                    end else begin
                        if lrecItemBOCHeader."Commodity Relationship" = lrecItemBOCHeader."Commodity Relationship"::Dependent then begin
                            exit;
                        end;
                    end;

                //</ENRE1.00>
                until lrecItemBOCLine.Next = 0;
            end else begin
                exit;
            end;
        end;
        //</ENRE1.00>

        lrecGLSetup.Get;
        Clear(ldecRebateAmtLCY);
        Clear(ldecRebateAmtRBT);
        Clear(ldecRebateAmtDOC);


        case lrecRebateSetup."Calculation Basis" of
            lrecRebateSetup."Calculation Basis"::"Pct. Sale($)":
                begin
                    //<ENRE1.00> - deleted code

                    //-- rebates can now be defined in different currencies so we need to calculate using doc. currency
                    lfrfQuantity := prrfLine.Field(15);
                    lfrfUOM := prrfLine.Field(13);

                    //<ENRE1.00>
                    grecSalesSetup.Get;

                    case grecSalesSetup."Rebate Price Source ELA" of
                        grecSalesSetup."Rebate Price Source ELA"::"Unit Price":
                            begin
                                lfrfUnitPrice := prrfLine.Field(22);
                                Evaluate(ldecUnitPrice, Format(lfrfUnitPrice.Value));
                            end;
                        grecSalesSetup."Rebate Price Source ELA"::"Delivered Unit Price":
                            begin
                                case lintTableNo of
                                    DATABASE::"Sales Line":
                                        begin
                                            lrecSalesLine.CalcDeliveredPrice2(ldecUnitPrice);
                                        end;
                                    DATABASE::"Sales Invoice Line":
                                        begin
                                            lrecSalesInvLine.CalcDeliveredPrice(ldecUnitPrice);
                                        end;
                                    DATABASE::"Sales Cr.Memo Line":
                                        begin
                                            lrecSalesCrMemoLine.CalcDeliveredPrice(ldecUnitPrice);
                                        end;
                                end;
                            end;
                    end;
                    //</ENRE1.00>

                    lfrfLineDiscountAmt := prrfLine.Field(28);
                    lfrfInvDiscountAmt := prrfLine.Field(69);

                    Evaluate(ldecLineQuantity, Format(lfrfQuantity.Value));
                    Evaluate(ldecLineDiscountAmt, Format(lfrfLineDiscountAmt.Value));
                    Evaluate(ldecInvDiscountAmt, Format(lfrfInvDiscountAmt.Value));

                    ldecLineAmount := (ldecLineQuantity * ldecUnitPrice) - (ldecLineDiscountAmt + ldecInvDiscountAmt);

                    grecSalesSetup.Get;

                    if grecSalesSetup."Calc. Rbt After Discount ELA" then begin
                        ldecRebateAmtDOC := (((ldecLineQuantity * ldecUnitPrice) - (ldecLineDiscountAmt + ldecInvDiscountAmt)) *
                                             (pdecRebateValue / 100));
                    end else begin
                        ldecRebateAmtDOC := ldecLineQuantity * ldecUnitPrice * (pdecRebateValue / 100);
                    end;

                    //-- Convert line amount to rebate currency
                    ldecLineAmount := lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lcodCurrencyCode,
                                                                       lrecRebateSetup."Currency Code", ldecLineAmount);

                    //<ENRE1.00>
                    if Abs(ldecLineAmount) < lrecRebateSetup."Minimum Amount" then
                        exit;
                    //</ENRE1.00>

                    //<ENRE1.00>
                    if (lrecRebateSetup."Maximum Amount" <> 0) and (Abs(ldecLineAmount) > lrecRebateSetup."Maximum Amount") then
                        exit;
                    //</ENRE1.00>

                    //-- Percentage rebates never have a currency so the rebate amount will always = doc amount
                    ldecRebateAmtRBT := ldecRebateAmtDOC;

                    //-- Convert doc amount to LCY if necessary
                    if lcodCurrencyCode = '' then begin
                        ldecRebateAmtLCY := ldecRebateAmtDOC;
                    end else begin
                        ldecRebateAmtLCY := lrecExchRate.ExchangeAmtFCYToLCY(ldtePostingDate,
                                               lcodCurrencyCode, ldecRebateAmtDOC, ldecCurrencyFactor);
                    end;

                    CreateRebateEntry(lrecRebateEntry."Functional Area"::Sales, prrfLine,
                                         pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                         pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);
                end;

            lrecRebateSetup."Calculation Basis"::"($)/Unit":
                begin
                    lfrfNo := prrfLine.Field(14228851);
                    if not lrecItem.Get(lfrfNo.Value) then
                        exit;

                    ldecRebateQtyPerUOM := 1;
                    if lrecRebateSetup."Unit of Measure Code" <> lrecItem."Base Unit of Measure" then
                        ldecRebateQtyPerUOM := lcduUOMMgt.GetQtyPerUnitOfMeasure(lrecItem, lrecRebateSetup."Unit of Measure Code");

                    lfrfQuantity := prrfLine.Field(15);
                    lfrfUOM := prrfLine.Field(13);
                    lfrfUnitPrice := prrfLine.Field(22);
                    lfrfLineDiscountAmt := prrfLine.Field(28);
                    lfrfInvDiscountAmt := prrfLine.Field(69);

                    //<ENRE1.00>
                    lfrfFieldRef := prrfLine.Field(5404);
                    Evaluate(ldecLineQtyPerUOM, Format(lfrfFieldRef.Value));
                    //</ENRE1.00>

                    //<ENRE1.00> - deleted code

                    Evaluate(ldecLineQuantity, Format(lfrfQuantity.Value));
                    Evaluate(ldecUnitPrice, Format(lfrfUnitPrice.Value));
                    Evaluate(ldecLineDiscountAmt, Format(lfrfLineDiscountAmt.Value));
                    Evaluate(ldecInvDiscountAmt, Format(lfrfInvDiscountAmt.Value));

                    ldecLineAmount := (ldecLineQuantity * ldecUnitPrice) - (ldecLineDiscountAmt + ldecInvDiscountAmt);

                    //<ENRE1.00>
                    ldecQtyBase := lcduUOMMgt.CalcBaseQty(ldecLineQuantity,
                                                           ldecLineQtyPerUOM);

                    if Abs(ldecQtyBase) < lrecRebateSetup."Minimum Quantity (Base)" then
                        exit;

                    if (lrecRebateSetup."Maximum Quantity (Base)" <> 0) and
                      (Abs(ldecQtyBase) > lrecRebateSetup."Maximum Quantity (Base)") then
                        exit;

                    lblnVariableWeight := lcduVariableWeightManagement.IsCatchWeightItem(pcodItemNo, false);

                    if (
                      (lblnVariableWeight)
                    ) then begin
                        lrecInvSetup.Get;
                        lrecInvSetup.TestField("Standard Weight UOM ELA");
                        lrecRebateSetup.TestField("Unit of Measure Code");
                        lrecRebateUnitOfMeasure.Get(lrecRebateSetup."Unit of Measure Code");
                        lblnVariableWeight := lrecRebateUnitOfMeasure."UOM Group Code ELA" = lrecInvSetup."Weight UOM Group ELA";
                    end;

                    if (
                      (lblnVariableWeight)
                    ) then begin
                        case lintTableNo of
                            DATABASE::"Sales Line":
                                begin
                                    Clear(lrecLineWeightStats);
                                    lcduVariableWeightManagement.CalcLineWeightStats(prrfLine, lrecLineWeightStats, 0);
                                    ldecWeight := lrecLineWeightStats."Total Net Weight";
                                end;

                            DATABASE::"Sales Invoice Line":
                                begin
                                    //<ENRE1.00>
                                    ldecWeight := lrecSalesInvLine."Line Net Weight ELA";
                                    //</ENRE1.00>
                                end;
                            DATABASE::"Sales Cr.Memo Line":
                                begin
                                    //<ENRE1.00>
                                    ldecWeight := lrecSalesCrMemoLine."Line Net Weight ELA";
                                    //</ENRE1.00>
                                end;
                            else begin
                                    Error(lctxtInvalidSalesLineTable);
                                end;
                        end;

                        if (
                          (lrecRebateSetup."Unit of Measure Code" = lrecInvSetup."Standard Weight UOM ELA")
                        ) then begin
                            ldecRebateUOMQtySold := ldecWeight;
                        end else begin
                            ldecRebateUOMQtySold := ldecWeight / lrecRebateUnitOfMeasure."Std. Qty. Per UOM ELA";
                        end;

                    end else begin
                        if (
                          (lrecRebateSetup."Unit of Measure Code" = Format(lfrfUOM))
                        ) then begin
                            ldecRebateUOMQtySold := ldecLineQuantity;
                        end else begin
                            ldecRebateUOMQtySold := ldecLineQuantity * ldecLineQtyPerUOM / ldecRebateQtyPerUOM;
                        end;
                    end;

                    //</ENRE1.00>

                    //-- SCENARIO 1 - rebate currency = sales order currency
                    if lrecRebateSetup."Currency Code" = lcodCurrencyCode then begin
                        //<ENRE1.00>
                        if Abs(ldecLineAmount) < lrecRebateSetup."Minimum Amount" then
                            exit;
                        //</ENRE1.00>

                        //<ENRE1.00>
                        if (lrecRebateSetup."Maximum Amount" <> 0) and (Abs(ldecLineAmount) > lrecRebateSetup."Maximum Amount") then
                            exit;
                        //</ENRE1.00>

                        //-- use the exchange rate on the sales header
                        ldecRebateAmtDOC := ldecRebateUOMQtySold * pdecRebateValue; //<ENRE1.00>

                        ldecRebateAmtRBT := ldecRebateAmtDOC;

                        if lcodCurrencyCode = '' then begin
                            ldecRebateAmtLCY := ldecRebateAmtDOC;
                        end else begin
                            if lrecRebateSetup."Currency Code" <> lrecGLSetup."LCY Code" then begin
                                ldecRebateAmtLCY := ldecRebateUOMQtySold * //<ENRE1.00>
                                  lrecExchRate.ExchangeAmtFCYToLCY(ldtePostingDate,
                                  lrecRebateSetup."Currency Code", pdecRebateValue, ldecCurrencyFactor);
                            end else begin
                                ldecRebateAmtLCY := ldecRebateAmtDOC;
                            end;
                        end;

                        CreateRebateEntry(lrecRebateEntry."Functional Area"::Sales, prrfLine,
                                             pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                             pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);


                        //-- SCENARIO 2 - rebate currency <> sales order currency & neither are LCY
                    end else
                        if (lrecRebateSetup."Currency Code" <> lcodCurrencyCode) and
                 ((lrecRebateSetup."Currency Code" <> '') and (lcodCurrencyCode <> '')) then begin
                            //-- convert the rebate to the currency of the sales order using the exchange rate of the order posting date
                            //<ENRE1.00>
                            if Abs(ldecLineAmount) < lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lrecRebateSetup."Currency Code",
                                                                                      lcodCurrencyCode, lrecRebateSetup."Minimum Amount") then
                                exit;
                            //</ENRE1.00>

                            //<ENRE1.00>
                            if (lrecRebateSetup."Maximum Amount" <> 0) and
                              (Abs(ldecLineAmount) > lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lrecRebateSetup."Currency Code",
                                                                                      lcodCurrencyCode, lrecRebateSetup."Maximum Amount")) then
                                exit;
                            //</ENRE1.00>

                            ldecRebateAmtDOC := ldecRebateUOMQtySold * //<ENRE1.00>
                                                lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate,
                                                lrecRebateSetup."Currency Code",
                                                lcodCurrencyCode, pdecRebateValue);
                            ldecRebateAmtLCY := ldecRebateUOMQtySold * //<ENRE1.00>
                                                lrecExchRate.ExchangeAmtFCYToLCY(ldtePostingDate,
                                                lcodCurrencyCode, ldecRebateAmtDOC, ldecCurrencyFactor);

                            ldecRebateAmtRBT := ldecRebateUOMQtySold * pdecRebateValue; //<ENRE1.00>

                            CreateRebateEntry(lrecRebateEntry."Functional Area"::Sales, prrfLine,
                                                 pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                                 pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);


                            //-- SCENARIO 3 - rebate = CAD and sales order <> CAD
                        end else
                            if ((lrecRebateSetup."Currency Code" = '') and (lcodCurrencyCode <> '')) then begin
                                //-- convert the rebate using exchange rate on sales header

                                //<ENRE1.00>
                                if Abs(ldecLineAmount) < lrecExchRate.ExchangeAmtLCYToFCYOnlyFactor(lrecRebateSetup."Minimum Amount", ldecCurrencyFactor)
                                  then
                                    exit;
                                //</ENRE1.00>

                                //<ENRE1.00>
                                if (lrecRebateSetup."Maximum Amount" <> 0) and
                                   (Abs(ldecLineAmount) > lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lrecRebateSetup."Currency Code",
                                                                                          lcodCurrencyCode, lrecRebateSetup."Maximum Amount")) then
                                    exit;
                                //</ENRE1.00>
                                ldecRebateAmtLCY := ldecRebateUOMQtySold * pdecRebateValue; //<ENRE1.00>
                                ldecRebateAmtRBT := ldecRebateAmtLCY;
                                ldecRebateAmtDOC := lrecExchRate.ExchangeAmtLCYToFCYOnlyFactor(ldecRebateAmtLCY, ldecCurrencyFactor);

                                CreateRebateEntry(lrecRebateEntry."Functional Area"::Sales, prrfLine,
                                                     pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                                     pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);


                                //-- SCENARIO 4 - rebate <> CAD and sales order = CAD
                            end else
                                if (lrecRebateSetup."Currency Code" <> '') and (lcodCurrencyCode = '') then begin
                                    //-- convert to currency on sales header using exchange rate as per sales header posting date

                                    //<ENRE1.00>
                                    if Abs(ldecLineAmount) < lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lrecRebateSetup."Currency Code",
                                                                                              lcodCurrencyCode, lrecRebateSetup."Minimum Amount") then
                                        exit;
                                    //</ENRE1.00>

                                    //<ENRE1.00>
                                    if (lrecRebateSetup."Maximum Amount" <> 0) and
                                      (Abs(ldecLineAmount) > lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lrecRebateSetup."Currency Code",
                                                                                              lcodCurrencyCode, lrecRebateSetup."Maximum Amount")) then
                                        exit;
                                    //</ENRE1.00>

                                    ldecRebateAmtLCY := ldecRebateUOMQtySold * //<ENRE1.00>
                                                     lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate,
                                                     lrecRebateSetup."Currency Code",
                                                     lcodCurrencyCode, pdecRebateValue);
                                    ldecRebateAmtDOC := ldecRebateAmtLCY;

                                    ldecRebateAmtRBT := ldecRebateUOMQtySold * pdecRebateValue; //<ENRE1.00>

                                    CreateRebateEntry(lrecRebateEntry."Functional Area"::Sales, prrfLine,
                                                         pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                                         pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);
                                end;
                end;
            //<ENRE1.00>
            lrecRebateSetup."Calculation Basis"::Commodity:
                begin

                    ldecRebateAmtLCY := pdecRebateValue;
                    ldecRebateAmtDOC := pdecRebateValue;

                    ldecRebateAmtRBT := pdecRebateValue;

                    CreateRebateEntry(lrecRebateEntry."Functional Area"::Sales, prrfLine,
                                         pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                         pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);

                end;
        //</ENRE1.00>
        end;

    end;


    procedure CreateRebateEntry(poptFunctionalArea: Option Sales,Purchase; prrfLine: RecordRef; pcodRebateCode: Code[20]; pdecAmountLCY: Decimal; pdecAmountRBT: Decimal; pdecAmountDOC: Decimal; pbolIsPeriodic: Boolean; pbolAdjustment: Boolean; pdecRebateValue: Decimal; pcodItemNo: Code[20]; var precTempRebateEntry: Record "Rebate Entry ELA" temporary; pcodCurrencyCode: Code[10])
    var
        lrecSalesHeader: Record "Sales Header";
        lrecSalesInv: Record "Sales Invoice Header";
        lrecSalesCrMemo: Record "Sales Cr.Memo Header";
        lrecRebateEntry: Record "Rebate Entry ELA";
        lrecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
        lrecRebateEntry2: Record "Rebate Entry ELA";
        lrecPostedRebateEntry2: Record "Rebate Ledger Entry ELA";
        lintEntryNo: Integer;
        lintTableNo: Integer;
        lfrfRbtDocType: FieldRef;
        lfrfRbtDocNo: FieldRef;
        lfrfRbtDocLineNo: FieldRef;
        lfrfBillToCustomer: FieldRef;
        lfrfSellToCustomer: FieldRef;
        lfrfPostingDate: FieldRef;
        lfrfFieldRef: FieldRef;
        lfrfDocCurrencyCode: FieldRef;
        lrecRebateHeader: Record "Rebate Header ELA";
        lrecCommodityLedger: Record "Commodity Ledger ELA";
        lrecCommodityEntry: Record "Commodity Entry ELA";
    begin
        lintTableNo := prrfLine.Number;

        if not pbolIsPeriodic then begin
            case lintTableNo of
                37:
                    begin
                        lrecRebateEntry2.Reset;
                        lrecRebateEntry2.LockTable;

                        if lrecRebateEntry2.FindLast then begin
                            lintEntryNo := lrecRebateEntry2."Entry No." + 1;
                        end else begin
                            lintEntryNo := 1;
                        end;

                        lrecRebateEntry.Init;

                        lrecRebateEntry."Entry No." := lintEntryNo;
                        lrecRebateEntry."Functional Area" := poptFunctionalArea;
                        lfrfRbtDocType := prrfLine.Field(1);
                        lrecRebateEntry."Source Type" := lfrfRbtDocType.Value;
                        lfrfRbtDocNo := prrfLine.Field(3);

                        //-- Populate Sell/Bill-To Customer, Ship-to, etc.
                        lrecRebateEntry.Validate("Source No.", Format(lfrfRbtDocNo.Value));

                        lfrfRbtDocLineNo := prrfLine.Field(4);
                        lrecRebateEntry."Source Line No." := lfrfRbtDocLineNo.Value;

                        //<ENRE1.00>
                        lrecRebateEntry."Currency Code (DOC)" := pcodCurrencyCode;
                        lrecRebateHeader.Get(pcodRebateCode);
                        lrecRebateEntry."Currency Code (RBT)" := lrecRebateHeader."Currency Code";
                        //</ENRE1.00>

                        lrecRebateEntry.Validate("Rebate Code", pcodRebateCode);

                        lrecRebateEntry.Validate("Item No.", pcodItemNo);

                        //<ENRE1.00>
                        //-- Set Accrual Customer No.
                        lrecRebateEntry."Post-to Customer No." := GetAccrualCustomer(pcodRebateCode,
                                                                    lrecRebateEntry."Sell-to Customer No.",
                                                                    lrecRebateEntry."Bill-To Customer No.");
                        //</ENRE1.00>

                        if (Format(lfrfRbtDocType.Value) = '3') or (Format(lfrfRbtDocType.Value) = '5') then begin
                            lrecRebateEntry.Validate("Amount (LCY)", -pdecAmountLCY);
                            lrecRebateEntry.Validate("Amount (RBT)", -pdecAmountRBT);
                            lrecRebateEntry.Validate("Amount (DOC)", -pdecAmountDOC);
                        end else begin
                            lrecRebateEntry.Validate("Amount (LCY)", pdecAmountLCY);
                            lrecRebateEntry.Validate("Amount (RBT)", pdecAmountRBT);
                            lrecRebateEntry.Validate("Amount (DOC)", pdecAmountDOC);
                        end;

                        if (lrecRebateEntry."Amount (LCY)" <> 0) or
                           (lrecRebateEntry."Amount (RBT)" <> 0) or
                           (lrecRebateEntry."Amount (DOC)" <> 0) then
                            lrecRebateEntry.Insert(true);

                        //<ENRE1.00>
                        grecCommodityLedgerTemp.Reset;
                        if grecCommodityLedgerTemp.FindSet then begin
                            repeat
                                lrecCommodityEntry.Init;
                                lrecCommodityEntry.TransferFields(grecCommodityLedgerTemp);
                                lrecCommodityEntry."Entry No." := 0;
                                lrecCommodityEntry."Rebate Entry No." := lintEntryNo;
                                lrecCommodityEntry."Source Type" := lfrfRbtDocType.Value;
                                lrecCommodityEntry.Validate("Source No.", Format(lfrfRbtDocNo.Value));
                                lrecCommodityEntry."Source Line No." := lfrfRbtDocLineNo.Value;
                                lrecCommodityEntry.Insert;
                            until grecCommodityLedgerTemp.Next = 0;
                        end;
                        //</ENRE1.00>

                    end;
                113, 115:
                    begin
                        lrecPostedRebateEntry2.Reset;
                        lrecPostedRebateEntry2.LockTable;
                        if lrecPostedRebateEntry2.FindLast then begin
                            lintEntryNo := lrecPostedRebateEntry2."Entry No." + 1;
                        end else begin
                            lintEntryNo := 1;
                        end;

                        lrecPostedRebateEntry.Init;
                        lrecPostedRebateEntry."Entry No." := lintEntryNo;
                        lrecPostedRebateEntry."Functional Area" := poptFunctionalArea;
                        //<ENRE1.00>
                        case lintTableNo of
                            113:
                                begin
                                    lrecPostedRebateEntry."Source Type" := lrecPostedRebateEntry."Source Type"::"Posted Invoice";
                                end;
                            115:
                                begin
                                    lrecPostedRebateEntry."Source Type" := lrecPostedRebateEntry."Source Type"::"Posted Cr. Memo";
                                end;
                        end;
                        //</ENRE1.00>

                        lfrfRbtDocNo := prrfLine.Field(3);
                        lrecPostedRebateEntry."Source No." := lfrfRbtDocNo.Value;

                        lfrfRbtDocLineNo := prrfLine.Field(4);
                        lrecPostedRebateEntry."Source Line No." := lfrfRbtDocLineNo.Value;

                        //<ENRE1.00>
                        lrecPostedRebateEntry."Currency Code (DOC)" := pcodCurrencyCode;
                        lrecRebateHeader.Get(pcodRebateCode);
                        lrecPostedRebateEntry."Currency Code (RBT)" := lrecRebateHeader."Currency Code";
                        //</ENRE1.00>

                        //<ENRE1.00>
                        if lrecRebateHeader."Job No." <> '' then
                            lrecPostedRebateEntry."Job No." := lrecRebateHeader."Job No.";

                        if lrecRebateHeader."Job Task No." <> '' then
                            lrecPostedRebateEntry."Job Task No." := lrecRebateHeader."Job Task No.";
                        //</ENRE1.00>

                        lrecPostedRebateEntry.Validate("Rebate Code", pcodRebateCode);

                        lfrfBillToCustomer := prrfLine.Field(68);
                        lrecPostedRebateEntry."Bill-to Customer No." := lfrfBillToCustomer.Value;

                        lfrfSellToCustomer := prrfLine.Field(2);
                        lrecPostedRebateEntry."Sell-to Customer No." := lfrfSellToCustomer.Value;

                        //<ENRE1.00>
                        case lrecPostedRebateEntry."Functional Area" of
                            lrecPostedRebateEntry."Functional Area"::Sales:
                                begin
                                    case lrecPostedRebateEntry."Source Type" of
                                        lrecPostedRebateEntry."Source Type"::"Posted Invoice":
                                            begin
                                                if lrecSalesInv.Get(lrecPostedRebateEntry."Source No.") then
                                                    lrecPostedRebateEntry."Ship-to Code" := lrecSalesInv."Ship-to Code";
                                            end;
                                        lrecPostedRebateEntry."Source Type"::"Posted Cr. Memo":
                                            begin
                                                if lrecSalesCrMemo.Get(lrecPostedRebateEntry."Source No.") then
                                                    lrecPostedRebateEntry."Ship-to Code" := lrecSalesCrMemo."Ship-to Code";
                                            end;
                                    end;
                                end;
                        end;
                        //</ENRE1.00>

                        lrecPostedRebateEntry.Validate("Item No.", pcodItemNo);

                        lfrfPostingDate := prrfLine.Field(131);
                        lrecPostedRebateEntry."Posting Date" := lfrfPostingDate.Value;

                        //<ENRE1.00>
                        //-- Set Accrual Customer No.
                        lrecPostedRebateEntry."Post-to Customer No." := GetAccrualCustomer(pcodRebateCode,
                                                                          lrecPostedRebateEntry."Sell-to Customer No.",
                                                                          lrecPostedRebateEntry."Bill-to Customer No.");
                        //</ENRE1.00>

                        case lintTableNo of
                            113:
                                begin
                                    lrecPostedRebateEntry."Source Type" := lrecPostedRebateEntry."Source Type"::"Posted Invoice";
                                    lrecPostedRebateEntry.Validate("Amount (LCY)", pdecAmountLCY);
                                    lrecPostedRebateEntry.Validate("Amount (RBT)", pdecAmountRBT);
                                    lrecPostedRebateEntry.Validate("Amount (DOC)", pdecAmountDOC);
                                end;
                            115:
                                begin
                                    lrecPostedRebateEntry."Source Type" := lrecPostedRebateEntry."Source Type"::"Posted Cr. Memo";
                                    lrecPostedRebateEntry.Validate("Amount (LCY)", -pdecAmountLCY);
                                    lrecPostedRebateEntry.Validate("Amount (RBT)", -pdecAmountRBT);
                                    lrecPostedRebateEntry.Validate("Amount (DOC)", -pdecAmountDOC);
                                end;
                        end;

                        if (lrecPostedRebateEntry."Amount (LCY)" <> 0) or
                           (lrecPostedRebateEntry."Amount (RBT)" <> 0) or
                           (lrecPostedRebateEntry."Amount (DOC)" <> 0) then
                            lrecPostedRebateEntry.Insert(true);

                        //<ENRE1.00>
                        grecCommodityLedgerTemp.Reset;
                        if grecCommodityLedgerTemp.FindSet then begin
                            repeat
                                lrecCommodityLedger.Init;
                                lrecCommodityLedger.TransferFields(grecCommodityLedgerTemp);
                                lrecCommodityLedger."Entry No." := 0;
                                lrecCommodityLedger."Rebate Ledger Entry No." := lintEntryNo;
                                lrecCommodityLedger.Insert;
                            until grecCommodityLedgerTemp.Next = 0;
                        end;
                        //</ENRE1.00>
                    end;
            end;
        end else begin
            if precTempRebateEntry.Find('+') then begin
                lintEntryNo := precTempRebateEntry."Entry No." + 1;
            end else begin
                lintEntryNo := 1;
            end;

            precTempRebateEntry.Init;

            precTempRebateEntry."Entry No." := lintEntryNo;
            precTempRebateEntry."Functional Area" := poptFunctionalArea;

            //<ENRE1.00>
            lfrfFieldRef := prrfLine.Field(3);
            precTempRebateEntry."Source No." := lfrfFieldRef.Value;

            lfrfFieldRef := prrfLine.Field(4);
            precTempRebateEntry."Source Line No." := lfrfFieldRef.Value;
            //</ENRE1.00>

            //<ENRE1.00>
            precTempRebateEntry."Currency Code (DOC)" := pcodCurrencyCode;
            lrecRebateHeader.Get(pcodRebateCode);
            precTempRebateEntry."Currency Code (RBT)" := lrecRebateHeader."Currency Code";
            //</ENRE1.00>

            precTempRebateEntry.Validate("Rebate Code", pcodRebateCode);

            precTempRebateEntry.Validate("Item No.", pcodItemNo);

            lfrfBillToCustomer := prrfLine.Field(68);
            precTempRebateEntry."Bill-To Customer No." := lfrfBillToCustomer.Value;

            lfrfSellToCustomer := prrfLine.Field(2);
            precTempRebateEntry."Sell-to Customer No." := lfrfSellToCustomer.Value;

            case lintTableNo of
                37:
                    begin
                        lfrfRbtDocType := prrfLine.Field(1);
                        precTempRebateEntry."Source Type" := lfrfRbtDocType.Value;
                    end;
                113:
                    begin
                        precTempRebateEntry."Source Type" := precTempRebateEntry."Source Type"::"Posted Invoice";
                        precTempRebateEntry.Validate("Amount (LCY)", pdecAmountLCY);
                        precTempRebateEntry.Validate("Amount (RBT)", pdecAmountRBT);
                        precTempRebateEntry.Validate("Amount (DOC)", pdecAmountDOC);

                        lfrfPostingDate := prrfLine.Field(131);
                        precTempRebateEntry."Posting Date" := lfrfPostingDate.Value;
                    end;
                115:
                    begin
                        precTempRebateEntry."Source Type" := precTempRebateEntry."Source Type"::"Posted Cr. Memo";
                        precTempRebateEntry.Validate("Amount (LCY)", -pdecAmountLCY);
                        precTempRebateEntry.Validate("Amount (RBT)", -pdecAmountRBT);
                        precTempRebateEntry.Validate("Amount (DOC)", -pdecAmountDOC);

                        lfrfPostingDate := prrfLine.Field(131);
                        precTempRebateEntry."Posting Date" := lfrfPostingDate.Value;
                    end;
            end;

            //<ENRE1.00>
            case precTempRebateEntry."Functional Area" of
                precTempRebateEntry."Functional Area"::Sales:
                    begin
                        if lrecSalesHeader.Get(precTempRebateEntry."Source Type", precTempRebateEntry."Source No.") then
                            precTempRebateEntry."Ship-To Code" := lrecSalesHeader."Ship-to Code";
                    end;
            end;

            //-- Set Accrual Customer No.
            precTempRebateEntry."Post-to Customer No." := GetAccrualCustomer(pcodRebateCode,
                                                              precTempRebateEntry."Sell-to Customer No.",
                                                              precTempRebateEntry."Bill-To Customer No.");
            //</ENRE1.00>

            if (precTempRebateEntry."Amount (LCY)" <> 0) or
               (precTempRebateEntry."Amount (RBT)" <> 0) or
               (precTempRebateEntry."Amount (DOC)" <> 0) then
                precTempRebateEntry.Insert(true);
        end;
    end;


    procedure CalcSalesDocRebate(prrfHeader: RecordRef; pblnPeriodicCalc: Boolean; pblnForceDocRebatesOnly: Boolean)
    var
        lrrfLine: RecordRef;
        lfrfHdrDocType: FieldRef;
        lfrfHdrDocNo: FieldRef;
        lfrfLineDocType: FieldRef;
        lfrfLineDocNo: FieldRef;
        lfrfLineType: FieldRef;
        lfrfLineQtyInvoiced: FieldRef;
        lfrfBypassCalc: FieldRef;
        lintTableNo: Integer;
        lrecTempRebateEntry: Record "Rebate Entry ELA" temporary;
        lfrfFieldRef: FieldRef;
        lfrfFieldRef2: FieldRef;
    begin
        //Delete all existing rebate entry

        DeleteRebateEntryLines(prrfHeader);

        //<ENRE1.00>
        if not gblnBypassPurchRebates then begin
            gcduPurchRebateMgmt.DeleteRebateEntryLines(prrfHeader);
        end;
        //</ENRE1.00>

        lintTableNo := prrfHeader.Number;
        case lintTableNo of
            36:
                begin
                    lfrfHdrDocType := prrfHeader.Field(1);

                    //<ENRE1.00>
                    grecSalesSetup.Get;
                    if grecSalesSetup."Frc Appl On SalesReturns ELA" then begin
                        //</ENRE1.00>
                        // Credit Memo -> Applies-to Doc. Type must be invoice and Applies-to Doc. No. not be blank
                        if (Format(lfrfHdrDocType.Value) = '3') then begin
                            //<ENRE1.00>
                            lfrfFieldRef := prrfHeader.Field(52);
                            lfrfFieldRef2 := prrfHeader.Field(53);

                            if not ((Format(lfrfFieldRef.Value) = '2') and (Format(lfrfFieldRef2.Value) <> '')) then begin
                                exit;
                            end;
                            //</ENRE1.00>
                        end;
                    end;//<ENRE1.00>
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lfrfBypassCalc := prrfHeader.Field(14229403); //ENRE1.00

                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;

                    lrrfLine.Open(37);
                    lfrfLineDocType := lrrfLine.Field(1);
                    lfrfLineDocType.SetFilter(Format(lfrfHdrDocType.Value));
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    //-- no need to recalculate lines that have already been invoiced
                    //-- periodic routine will pick up the posted rebate and will apply any differences to the invoice
                    lfrfLineQtyInvoiced := lrrfLine.Field(61);
                    //<ENRE1.00> - deleted code
                end;
            112:
                begin
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lrrfLine.Open(113);
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));

                    lfrfBypassCalc := prrfHeader.Field(14229420);

                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;
                end;
            114:
                begin
                    lfrfHdrDocNo := prrfHeader.Field(3);

                    //<ENRE1.00>
                    grecSalesSetup.Get;
                    if grecSalesSetup."Frc Appl On SalesReturns ELA" then begin
                        //</ENRE1.00>
                        //Posted Cr. Memo -> must have Return Order No. or Applies-to Doc. Type must be invoice and Applies-to Doc. No. not be blank
                        //<ENRE1.00>
                        lfrfFieldRef := prrfHeader.Field(52);
                        lfrfFieldRef2 := prrfHeader.Field(53);

                        if not ((Format(lfrfFieldRef.Value) = '2') and (Format(lfrfFieldRef2.Value) <> '')) then begin
                            exit;
                        end;
                        //</ENRE1.00>
                    end; //<ENRE1.00>

                    lrrfLine.Open(115);
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));

                    lfrfBypassCalc := prrfHeader.Field(14229420);

                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;
                end;
            else begin
                    Error('');
                end;
        end;

        if pblnForceDocRebatesOnly then
            //<ENRE1.00>
            grecRebateHeaderFilter.SetFilter("Rebate Type", '%1|%2|%3',
                                           grecRebateHeaderFilter."Rebate Type"::"Off-Invoice",
                                           grecRebateHeaderFilter."Rebate Type"::Everyday,
                                           grecRebateHeaderFilter."Rebate Type"::Commodity);

        //</ENRE1.00>

        //<ENRE1.00>
        rdOnBeforeFilterLines(prrfHeader, lrrfLine);
        //<ENRE1.00>

        if lrrfLine.Find('-') then begin
            repeat
                CalcRebate(lrrfLine, pblnPeriodicCalc, lrecTempRebateEntry);
            until lrrfLine.Next = 0;
        end;

        //<ENRE1.00>
        if not gblnBypassPurchRebates then begin
            gcduPurchRebateMgmt.CalcSalesBasedPurchRebate(prrfHeader, pblnPeriodicCalc, pblnForceDocRebatesOnly);
        end;
        //</ENRE1.00>
    end;


    procedure DeleteRebateEntryLines(prrfHeader: RecordRef)
    var
        lrecRebateEntry: Record "Rebate Entry ELA";
        lintTableNo: Integer;
        lfrfFieldRef: FieldRef;
        lrecCommodityEntry: Record "Commodity Entry ELA";
    begin
        lintTableNo := prrfHeader.Number;
        case lintTableNo of
            36:
                begin
                    //<ENRE1.00>
                    lfrfFieldRef := prrfHeader.Field(1);
                    lrecRebateEntry.SetFilter("Source Type", Format(lfrfFieldRef.Value));
                    //</ENRE1.00>

                    //<ENRE1.00>
                    lrecCommodityEntry.SetFilter("Source Type", Format(lfrfFieldRef.Value));
                    //</ENRE1.00>

                end;
        end;

        lfrfFieldRef := prrfHeader.Field(3);

        lrecRebateEntry.SetRange("Source No.", Format(lfrfFieldRef.Value));
        lrecRebateEntry.DeleteAll;

        //<ENRE1.00>
        lrecCommodityEntry.SetRange("Source No.", Format(lfrfFieldRef.Value));
        lrecCommodityEntry.DeleteAll;
        //</ENRE1.00>
    end;


    procedure DeleteRebateEntry(prrfLine: RecordRef)
    var
        lrecRebateEntry: Record "Rebate Entry ELA";
        lintTableNo: Integer;
        lintLineNo: Integer;
        lfrfFieldRef: FieldRef;
        lrecCommodityEntry: Record "Commodity Entry ELA";
    begin
        lintTableNo := prrfLine.Number;
        case lintTableNo of
            37:
                begin
                    //<ENRE1.00>
                    lfrfFieldRef := prrfLine.Field(1);
                    lrecRebateEntry.SetFilter("Source Type", Format(lfrfFieldRef.Value));

                    //<ENRE1.00>
                    lrecCommodityEntry.SetFilter("Source Type", Format(lfrfFieldRef.Value));
                    //</ENRE1.00>
                end;
        end;

        lfrfFieldRef := prrfLine.Field(3);
        lrecRebateEntry.SetRange("Source No.", Format(lfrfFieldRef.Value));

        lfrfFieldRef := prrfLine.Field(4);
        Evaluate(lintLineNo, Format(lfrfFieldRef.Value));

        lrecRebateEntry.SetRange("Source Line No.", lintLineNo);
        lrecRebateEntry.DeleteAll;

        //<ENRE1.00>
        lfrfFieldRef := prrfLine.Field(3);
        lrecCommodityEntry.SetRange("Source No.", Format(lfrfFieldRef.Value));
        lrecCommodityEntry.SetRange("Source Line No.", lintLineNo);

        lrecCommodityEntry.DeleteAll;
        //</ENRE1.00>
    end;


    procedure SetRebateFilter(var precRebateHeaderFilter: Record "Rebate Header ELA")
    begin
        grecRebateHeaderFilter.CopyFilters(precRebateHeaderFilter);
    end;


    procedure CalcLumpSumRebate(pdteAsOfDate: Date; precRebate: Record "Rebate Header ELA")
    var
        lrecCustomer: Record Customer;
        lrecTempCustomer: Record Customer temporary;
        lrecItem: Record Item;
        lrecTempItem: Record Item temporary;
        lrecRebateLedger: Record "Rebate Ledger Entry ELA";
        lrecRebateLine: Record "Rebate Line ELA";
        lrecRebateLine2: Record "Rebate Line ELA";
        lrecTempRebateLine: Record "Rebate Line ELA" temporary;
        lrecCurrExchange: Record "Currency Exchange Rate";
        ldecRebateValueToPost: Decimal;
        lintCustCount: Integer;
        ldecRebateValuePerEntry: Decimal;
        lintEntryNo: Integer;
        lintItemCount: Integer;
        ljxText000: Label 'An error has ocurred. No item criteria can be found for Lump Sum Rebate %1.';
        ltxtItemNoFilter: Text[1024];
        ltxtRebateGroupFilter: Text[1024];
        ltxtItemCategoryFilter: Text[1024];
        lText001: Label 'Customer No. %1 is blocked. The distribution for rebate %2 cannot continue.';
        lblnFoundHeaderFilter: Boolean;
    begin
        if precRebate."Rebate Type" <> precRebate."Rebate Type"::"Lump Sum" then
            exit;

        //<ENRE1.00>
        if precRebate.Blocked then
            exit;
        //</ENRE1.00>

        precRebate.TestField("Start Date");

        lintCustCount := 0;

        grecSalesSetup.Get;

        lrecCustomer.Reset;
        lrecItem.Reset;
        lrecRebateLedger.Reset;
        lrecRebateLine.Reset;

        lrecTempCustomer.Reset;
        lrecTempCustomer.DeleteAll;

        lrecTempItem.Reset;
        lrecTempItem.DeleteAll;

        //<ENRE1.00>
        lblnFoundHeaderFilter := false;
        //</ENRE1.00>

        //-- We need to post an entry ONLY if sum of rebate ledger entries is not equal to Rebate Value on rebate card
        lrecRebateLedger.SetCurrentKey("Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Code");

        lrecRebateLedger.SetRange("Functional Area", lrecRebateLedger."Functional Area"::Sales);
        lrecRebateLedger.SetRange("Source Type", lrecRebateLedger."Source Type"::Customer);
        lrecRebateLedger.SetRange("Source No.");
        lrecRebateLedger.SetRange("Source Line No.");
        lrecRebateLedger.SetRange("Rebate Code", precRebate.Code);

        lrecRebateLedger.CalcSums("Amount (RBT)");

        if lrecRebateLedger."Amount (RBT)" <> precRebate."Rebate Value" then begin
            //-- Calculate amount to post for this rebate
            ldecRebateValueToPost := precRebate."Rebate Value" - lrecRebateLedger."Amount (RBT)";

            if ldecRebateValueToPost <> 0 then begin
                //-- Determine how many customers apply to this lump sum rebate using header filters
                if grecSalesSetup."Use RbtHdr AppliesTo Filt ELA" then begin
                    case precRebate."Apply-To Customer Type" of
                        precRebate."Apply-To Customer Type"::All:
                            begin
                                //<ENRE1.00>
                                lblnFoundHeaderFilter := true;
                                //</ENRE1.00>
                                lrecCustomer.Reset;
                            end;
                        precRebate."Apply-To Customer Type"::Specific:
                            begin
                                //<ENRE1.00>
                                lblnFoundHeaderFilter := true;
                                //</ENRE1.00>
                                lrecCustomer.SetRange("No.", precRebate."Apply-To Customer No.");
                            end;
                        precRebate."Apply-To Customer Type"::Group:
                            begin
                                case precRebate."Apply-To Cust. Group Type" of
                                    precRebate."Apply-To Cust. Group Type"::"Rebate Group":
                                        begin
                                            //<ENRE1.00>
                                            lblnFoundHeaderFilter := true;
                                            //</ENRE1.00>
                                            if lrecCustomer.SetCurrentKey("Rebate Group Code ELA") then;
                                            lrecCustomer.SetRange("Rebate Group Code ELA", precRebate."Apply-To Cust. Group Code");
                                        end;
                                end;
                            end;
                    end;
                end;

                //<ENRE1.00>
                //-- Filter out blocked customers
                if grecSalesSetup."LumpSum Rbt Blk Cust Act ELA" = grecSalesSetup."LumpSum Rbt Blk Cust Act ELA"::Skip then
                    lrecCustomer.SetRange(Blocked, lrecCustomer.Blocked::" ");
                //</ENRE1.00>

                if lrecCustomer.FindSet then begin
                    repeat
                        lrecTempCustomer.Init;
                        lrecTempCustomer.TransferFields(lrecCustomer);
                        if lrecTempCustomer.Insert then;
                    until lrecCustomer.Next = 0;
                end;

                //---------------------------------------------------------------------------------------------------------------------------
                //---------------------------------------------------------------------------------------------------------------------------
                //-----------------DO NOT USE LRECCUSTOMER PAST THIS POINT. USE ONLY THE LRECTEMPCUSTOMER TABLE FOR PERFORMANCE!!!-----------
                //---------------------------------------------------------------------------------------------------------------------------
                //---------------------------------------------------------------------------------------------------------------------------
                if lrecTempCustomer.IsEmpty then
                    exit;

                //-- Load up rebate lines into temp table to avoid multiple reads back to server
                lrecRebateLine.Reset;
                lrecRebateLine.SetRange("Rebate Code", precRebate.Code);

                if not lrecRebateLine.IsEmpty then begin
                    lrecRebateLine.FindSet;

                    repeat
                        lrecTempRebateLine.Init;
                        lrecTempRebateLine.TransferFields(lrecRebateLine);
                        lrecTempRebateLine.Insert;
                    until lrecRebateLine.Next = 0;
                end;

                //---------------------------------------------------------------------------------------------------------------------------
                //---------------------------------------------------------------------------------------------------------------------------
                //--------------DO NOT USE LRECREBATELINE PAST THIS POINT. USE ONLY THE LRECTEMPREBATELIN TABLE FOR PERFORMANCE!!!-----------
                //---------------------------------------------------------------------------------------------------------------------------
                //---------------------------------------------------------------------------------------------------------------------------

                //-- Get rid of any customers that are specifically not allowed on this rebate
                if lrecTempCustomer.FindSet(true, true) then begin
                    if not lrecTempRebateLine.IsEmpty then begin
                        repeat
                            //-- check for specific customer no.
                            lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Customer);
                            lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"No.");
                            lrecTempRebateLine.SetRange(Value, lrecTempCustomer."No.");

                            if lrecTempRebateLine.FindFirst then begin
                                if not lrecTempRebateLine.Include then
                                    lrecTempCustomer.Delete;
                            end else begin
                                //-- look for customer rebate group
                                lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"Sub-type");
                                lrecTempRebateLine.SetRange(Value, lrecCustomer."Rebate Group Code ELA");

                                if lrecTempRebateLine.FindFirst then begin
                                    if not lrecTempRebateLine.Include then
                                        lrecTempCustomer.Delete;
                                end else begin
                                    if not lblnFoundHeaderFilter then begin
                                        lrecTempCustomer.Delete;
                                    end;
                                end;
                            end;
                        until lrecTempCustomer.Next = 0;
                    end;
                end;

                if lrecTempCustomer.IsEmpty then
                    exit;

                lintCustCount := lrecTempCustomer.Count;

                if lintCustCount <> 0 then begin
                    if grecSalesSetup."LumpSum Rbt Distribution ELA" =
                      grecSalesSetup."LumpSum Rbt Distribution ELA"::"Customer-Item" then begin

                        ltxtItemNoFilter := '';
                        ltxtRebateGroupFilter := '';
                        ltxtItemCategoryFilter := '';

                        //-- If not item details exist, then it applies to all items
                        lrecTempRebateLine.Reset;
                        lrecTempRebateLine.SetRange("Rebate Code", precRebate.Code);
                        lrecTempRebateLine.SetRange("Line No.");
                        lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);

                        if lrecTempRebateLine.FindSet then begin
                            //-- Build Filter strings
                            repeat
                                case lrecTempRebateLine.Type of
                                    lrecTempRebateLine.Type::"No.":
                                        begin
                                            if not lrecTempRebateLine.Include then begin
                                                lrecRebateLine2.SetRange("Rebate Code", lrecTempRebateLine."Rebate Code");
                                                lrecRebateLine2.SetRange("Line No.");
                                                lrecRebateLine2.SetRange(Source, lrecTempRebateLine.Source);
                                                lrecRebateLine2.SetRange(Type, lrecTempRebateLine.Type);
                                                lrecRebateLine2.SetRange("Sub-Type", lrecTempRebateLine."Sub-Type");
                                                lrecRebateLine2.SetRange(Include, true);

                                                if not lrecRebateLine2.FindFirst then begin
                                                    if ltxtItemNoFilter <> '' then
                                                        ltxtItemNoFilter := ltxtItemNoFilter + '&';

                                                    ltxtItemNoFilter := ltxtItemNoFilter + '<>' + lrecTempRebateLine.Value;
                                                end;
                                            end else begin
                                                if ltxtItemNoFilter <> '' then
                                                    ltxtItemNoFilter := ltxtItemNoFilter + '|';

                                                ltxtItemNoFilter := ltxtItemNoFilter + lrecTempRebateLine.Value;
                                            end;
                                        end;
                                    lrecTempRebateLine.Type::"Sub-type":
                                        begin
                                            case lrecTempRebateLine."Sub-Type" of
                                                lrecTempRebateLine."Sub-Type"::"Rebate Group":
                                                    begin
                                                        if not lrecTempRebateLine.Include then begin
                                                            lrecRebateLine2.SetRange("Rebate Code", lrecTempRebateLine."Rebate Code");
                                                            lrecRebateLine2.SetRange("Line No.");
                                                            lrecRebateLine2.SetRange(Source, lrecTempRebateLine.Source);
                                                            lrecRebateLine2.SetRange(Type, lrecTempRebateLine.Type);
                                                            lrecRebateLine2.SetRange("Sub-Type", lrecTempRebateLine."Sub-Type");
                                                            lrecRebateLine2.SetRange(Include, true);

                                                            if not lrecRebateLine2.FindFirst then begin
                                                                if ltxtRebateGroupFilter <> '' then
                                                                    ltxtRebateGroupFilter := ltxtRebateGroupFilter + '&';

                                                                ltxtRebateGroupFilter := ltxtRebateGroupFilter + '<>' + lrecTempRebateLine.Value;
                                                            end;
                                                        end else begin
                                                            if ltxtRebateGroupFilter <> '' then
                                                                ltxtRebateGroupFilter := ltxtRebateGroupFilter + '|';

                                                            ltxtRebateGroupFilter := ltxtRebateGroupFilter + lrecTempRebateLine.Value;
                                                        end;
                                                    end;
                                                lrecTempRebateLine."Sub-Type"::"Category Code":
                                                    begin
                                                        if not lrecTempRebateLine.Include then begin
                                                            lrecRebateLine2.SetRange("Rebate Code", lrecTempRebateLine."Rebate Code");
                                                            lrecRebateLine2.SetRange("Line No.");
                                                            lrecRebateLine2.SetRange(Source, lrecTempRebateLine.Source);
                                                            lrecRebateLine2.SetRange(Type, lrecTempRebateLine.Type);
                                                            lrecRebateLine2.SetRange("Sub-Type", lrecTempRebateLine."Sub-Type");
                                                            lrecRebateLine2.SetRange(Include, true);

                                                            if not lrecRebateLine2.FindFirst then begin
                                                                if ltxtItemCategoryFilter <> '' then
                                                                    ltxtItemCategoryFilter := ltxtItemCategoryFilter + '&';

                                                                ltxtItemCategoryFilter := ltxtItemCategoryFilter + '<>' + lrecTempRebateLine.Value;
                                                            end;
                                                        end else begin
                                                            if ltxtItemCategoryFilter <> '' then
                                                                ltxtItemCategoryFilter := ltxtItemCategoryFilter + '|';

                                                            ltxtItemCategoryFilter := ltxtItemCategoryFilter + lrecTempRebateLine.Value;
                                                        end;
                                                    end;

                                            end;
                                        end;
                                end;
                            until lrecTempRebateLine.Next = 0;
                        end;

                        //-- Load up temp table of applicable items, based on filters calculated above
                        lrecTempItem.Reset;
                        lrecTempItem.DeleteAll;

                        lrecItem.SetFilter("No.", ltxtItemNoFilter);
                        lrecItem.SetFilter("Rebate Group Code ELA", ltxtRebateGroupFilter);
                        lrecItem.SetFilter("Item Category Code", ltxtItemCategoryFilter);

                        if not lrecItem.IsEmpty then begin
                            lrecItem.FindSet;
                            repeat
                                lrecTempItem.Init;
                                lrecTempItem.TransferFields(lrecItem);
                                lrecTempItem.Insert;
                            until lrecItem.Next = 0;
                        end;

                        lintItemCount := lrecTempItem.Count;

                        if grecSalesSetup."Items Req on LumpSum Rbt ELA" then begin
                            if lrecTempItem.IsEmpty then
                                Error(ljxText000, precRebate.Code);
                        end;

                        //--------------------------------------------------------------------------------------------------------------------------
                        //--------------------------------------------------------------------------------------------------------------------------
                        //--------------DO NOT USE LRECITEM PAST THIS POINT. USE ONLY THE LRECTEMPITEM TABLE FOR PERFORMANCE!!!---------------------
                        //--------------------------------------------------------------------------------------------------------------------------
                        //--------------------------------------------------------------------------------------------------------------------------
                        if (lintCustCount <> 0) and (lintItemCount <> 0) then begin
                            //-- Round entry amount to 5 decimals (max decimals allowed on rebate header)
                            ldecRebateValuePerEntry := Round(ldecRebateValueToPost / lintCustCount / lintItemCount, 0.00001);

                            if lrecTempCustomer.FindSet then begin
                                lrecRebateLedger.Reset;

                                if lrecRebateLedger.FindLast then
                                    lintEntryNo := lrecRebateLedger."Entry No." + 1
                                else
                                    lintEntryNo := 1;

                                repeat
                                    if lrecTempItem.FindSet then begin
                                        //<ENRE1.00>
                                        if grecSalesSetup."LumpSum Rbt Blk Cust Act ELA" = grecSalesSetup."LumpSum Rbt Blk Cust Act ELA"::Error then
                                            if lrecTempCustomer.Blocked > 0 then
                                                Error(lText001, lrecCustomer."No.", precRebate.Code);
                                        //</ENRE1.00>

                                        repeat
                                            //-- Create unaccrued Rebate Ledger Entry
                                            lrecRebateLedger.Init;

                                            lrecRebateLedger."Entry No." := lintEntryNo;
                                            lrecRebateLedger."Functional Area" := lrecRebateLedger."Functional Area"::Sales;
                                            lrecRebateLedger."Source Type" := lrecRebateLedger."Source Type"::Customer;
                                            lrecRebateLedger."Source No." := lrecTempCustomer."No.";
                                            lrecRebateLedger."Source Line No." := 0;
                                            lrecRebateLedger."Posting Date" := precRebate."Start Date";
                                            lrecRebateLedger.Validate("Rebate Code", precRebate.Code);
                                            lrecRebateLedger.Validate("Item No.", lrecTempItem."No.");

                                            lrecRebateLedger.Validate("Amount (LCY)", lrecCurrExchange.ExchangeAmtFCYToFCY(
                                                                                     precRebate."Start Date",
                                                                                     precRebate."Currency Code", '', ldecRebateValuePerEntry));
                                            lrecRebateLedger.Validate("Amount (RBT)", ldecRebateValuePerEntry);
                                            lrecRebateLedger.Validate("Amount (DOC)", 0);

                                            lrecRebateLedger."Bill-to Customer No." := lrecTempCustomer."Bill-to Customer No.";

                                            if lrecRebateLedger."Bill-to Customer No." = '' then
                                                lrecRebateLedger."Bill-to Customer No." := lrecTempCustomer."No.";

                                            lrecRebateLedger."Sell-to Customer No." := lrecTempCustomer."No.";
                                            lrecRebateLedger."Ship-to Code" := '';

                                            lrecRebateLedger."Paid to Customer" := false;
                                            lrecRebateLedger."Posted To G/L" := false;

                                            //<ENRE1.00>
                                            lrecRebateLedger."Post-to Customer No." := GetAccrualCustomer(precRebate.Code,
                                                                                              lrecRebateLedger."Sell-to Customer No.",
                                                                                              lrecRebateLedger."Bill-to Customer No.");
                                            //</ENRE1.00>

                                            lrecRebateLedger.Insert(true);

                                            lintEntryNo += 1;
                                            ldecRebateValueToPost -= ldecRebateValuePerEntry;
                                        until lrecTempItem.Next = 0;
                                    end;
                                until (lrecTempCustomer.Next = 0) or (ldecRebateValueToPost = 0);

                                //-- Add remainder to rebate ledger entry created
                                if ldecRebateValueToPost <> 0 then begin
                                    //-- Create unaccrued Rebate Ledger Entry
                                    lrecRebateLedger.Validate("Amount (RBT)", lrecRebateLedger."Amount (RBT)" + ldecRebateValueToPost);
                                    lrecRebateLedger.Validate("Amount (LCY)", lrecCurrExchange.ExchangeAmtFCYToFCY(
                                                                             precRebate."Start Date",
                                                                             precRebate."Currency Code", '', lrecRebateLedger."Amount (RBT)"));
                                    lrecRebateLedger.Validate("Amount (DOC)", 0);

                                    lrecRebateLedger.Modify(true);
                                end;
                            end;
                        end;
                    end else begin
                        //-- ****
                        //-- Distribute rebate by customer only (ignore any item lines on the rebate)
                        //-- ****
                        if lintCustCount <> 0 then begin
                            //-- Round entry amount to 5 decimals (max decimals allowed on rebate header)
                            ldecRebateValuePerEntry := Round(ldecRebateValueToPost / lintCustCount, 0.00001);

                            if lrecTempCustomer.FindSet then begin
                                //<ENRE1.00>
                                if grecSalesSetup."LumpSum Rbt Blk Cust Act ELA" = grecSalesSetup."LumpSum Rbt Blk Cust Act ELA"::Error then
                                    if lrecTempCustomer.Blocked > 0 then
                                        Error(lText001, lrecTempCustomer."No.", precRebate.Code);
                                //</ENRE1.00>

                                lrecRebateLedger.Reset;
                                lrecRebateLedger.LockTable;

                                if lrecRebateLedger.FindLast then
                                    lintEntryNo := lrecRebateLedger."Entry No." + 1
                                else
                                    lintEntryNo := 1;

                                repeat
                                    //-- Create unaccrued Rebate Ledger Entry
                                    lrecRebateLedger.Init;

                                    lrecRebateLedger."Entry No." := lintEntryNo;
                                    lrecRebateLedger."Functional Area" := lrecRebateLedger."Functional Area"::Sales;
                                    lrecRebateLedger."Source Type" := lrecRebateLedger."Source Type"::Customer;
                                    lrecRebateLedger."Source No." := lrecTempCustomer."No.";
                                    lrecRebateLedger."Source Line No." := 0;
                                    lrecRebateLedger."Posting Date" := precRebate."Start Date";
                                    lrecRebateLedger.Validate("Rebate Code", precRebate.Code);

                                    lrecRebateLedger.Validate("Amount (LCY)", lrecCurrExchange.ExchangeAmtFCYToFCY(
                                                                             precRebate."Start Date",
                                                                             precRebate."Currency Code", '', ldecRebateValuePerEntry));
                                    lrecRebateLedger.Validate("Amount (RBT)", ldecRebateValuePerEntry);
                                    lrecRebateLedger.Validate("Amount (DOC)", 0);

                                    lrecRebateLedger."Bill-to Customer No." := lrecTempCustomer."Bill-to Customer No.";

                                    if lrecRebateLedger."Bill-to Customer No." = '' then
                                        lrecRebateLedger."Bill-to Customer No." := lrecTempCustomer."No.";

                                    lrecRebateLedger."Sell-to Customer No." := lrecTempCustomer."No.";
                                    lrecRebateLedger."Ship-to Code" := '';

                                    lrecRebateLedger."Paid to Customer" := false;
                                    lrecRebateLedger."Posted To G/L" := false;

                                    //<ENRE1.00>
                                    lrecRebateLedger."Post-to Customer No." := GetAccrualCustomer(precRebate.Code,
                                                                                      lrecRebateLedger."Sell-to Customer No.",
                                                                                      lrecRebateLedger."Bill-to Customer No.");
                                    //</ENRE1.00>

                                    lrecRebateLedger.Insert(true);

                                    lintEntryNo += 1;
                                    ldecRebateValueToPost -= ldecRebateValuePerEntry;
                                until (lrecTempCustomer.Next = 0) or (ldecRebateValueToPost = 0);

                                //-- Add remainder to rebate ledger entry created
                                if ldecRebateValueToPost <> 0 then begin
                                    //-- Create unaccrued Rebate Ledger Entry
                                    lrecRebateLedger.Validate("Amount (RBT)", lrecRebateLedger."Amount (RBT)" + ldecRebateValueToPost);
                                    lrecRebateLedger.Validate("Amount (LCY)", lrecCurrExchange.ExchangeAmtFCYToFCY(
                                                                             precRebate."Start Date",
                                                                             precRebate."Currency Code", '', lrecRebateLedger."Amount (RBT)"));
                                    lrecRebateLedger.Validate("Amount (DOC)", 0);

                                    lrecRebateLedger.Modify(true);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;


    procedure GetAccrualCustomer(pcodRebateCode: Code[20]; pcodSellToCustomer: Code[20]; pcodBillToCustomer: Code[20]): Code[20]
    var
        lrecRebate: Record "Rebate Header ELA";
        lrecCustomer: Record Customer;
        lrecCustBuyGrp: Record "Customer Buying Group ELA";
    begin
        //<ENRE1.00>
        //-- Normally, rebates are accrued against the Bill-To Customer that the source document is for. In the event
        //--  a Buying GRoup is used, the buying group will be attached ot the customer whom the sales transaction
        //--  ocurred (eg. Sell-To Customer). This is why we look for the buying group based on the sell-to customer. If
        //--  there is no buying group defined then we revert back to the original logic and use the Bill-To Customer.
        //--  UNDER NO CIRCUMSTANCES SHOULD THE REBATE BE ACCRUED DIRECTLY AGAINST THE SELL-TO CUSTOMER FIELD

        if (pcodRebateCode = '') or (pcodSellToCustomer = '') or (pcodBillToCustomer = '') then
            exit;

        if not lrecRebate.Get(pcodRebateCode) then
            exit;

        if lrecRebate."Post to Cust. Buying Group" then begin
            lrecCustomer.Get(pcodSellToCustomer);

            if lrecCustomer."Customer Buying Group ELA" <> '' then begin
                lrecCustBuyGrp.Get(lrecCustomer."Customer Buying Group ELA");

                lrecCustBuyGrp.TestField("Rebate Accrual Customer No.");

                exit(lrecCustBuyGrp."Rebate Accrual Customer No.");
            end else begin
                exit(pcodBillToCustomer);
            end;
        end else begin
            exit(pcodBillToCustomer);
        end;
        //</ENRE1.00>
    end;


    procedure AccrueRebateToCustomer(var precRebateLedgEntry: Record "Rebate Ledger Entry ELA"; pcodCustNo: Code[20])
    var
        lrecGenJnlLine: Record "Gen. Journal Line";
        lrecGLEntry: Record "G/L Entry";
        lrecCustLedgEntry: Record "Cust. Ledger Entry";
        lrecSourceCodeSetup: Record "Source Code Setup";
        lrecTEMPCustLedgEntry: Record "Cust. Ledger Entry" temporary;
        lrecRebateHeader: Record "Rebate Header ELA";
        lrecCurrency: Record Currency;
        lrecGLSetup: Record "General Ledger Setup";
        lrecRebateLedgEntry: Record "Rebate Ledger Entry ELA";
        lrecSalesSetup: Record "Sales & Receivables Setup";
        lrecJnlBatch: Record "Gen. Journal Batch";
        lfrmPostRebate: Page "Post Rebate To Customer ELA";
        loptAction: Option "Post Only","Post and Create Refund";
        lcodDocNo: Code[20];
        lcodInitDocNo: Code[20];
        ldtePostingDate: Date;
        lcduGenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        lText000: Label 'Cannot find a G/L Entry for Posted Rebate Entry No. %1, Account No. %2.';
        lcduNoSeriesMgt: Codeunit NoSeriesManagement;
        lintLineNo: Integer;
        ldecAmount: Decimal;
        ldlgWindow: Dialog;
        lintCount: Integer;
        lintCounter: Integer;
        lText001: Label 'Posting lines         #1###### @2@@@@@@@@@@@@@';
        lText002: Label 'Refund journal line no. %1 has been created in the %2 batch.';
        lblnPromoJobSourceSetupCheck: Boolean;
        lText003: Label 'Please enter a source code for "Job G/L Journal" and "Job G/L WIP".';
        DimMgt: Codeunit DimensionManagement;
    begin
        //<ENRE1.00>
        Error('Inside Accrue');
        if pcodCustNo = '' then
            exit;

        lrecSourceCodeSetup.Get;
        lrecGLSetup.Get;
        lrecSalesSetup.Get;

        //<ENRE1.00>
        lblnPromoJobSourceSetupCheck := false;
        //</ENRE1.00>
        ldecAmount := 0;

        Clear(lcduNoSeriesMgt);

        Clear(lrecTEMPCustLedgEntry);
        lrecTEMPCustLedgEntry.DeleteAll;

        lrecSalesSetup.TestField("Rebate Document Nos. ELA");

        //-- Get next number but do not commit it until the user selects OK to psot teh entries
        lcodInitDocNo := lcduNoSeriesMgt.GetNextNo(lrecSalesSetup."Rebate Document Nos. ELA", WorkDate, false);

        if not gblnUseDefaultPostingValues then begin

            lfrmPostRebate.SetValues(lcodInitDocNo, WorkDate, 1);
            lfrmPostRebate.LookupMode(true);
            if ACTION::LookupOK = lfrmPostRebate.RunModal then begin
                lfrmPostRebate.GetValues(lcodDocNo, ldtePostingDate, loptAction);
            end else begin
                exit;
            end;

        end else begin

            lcodDocNo := lcodInitDocNo;
            ldtePostingDate := WorkDate;
            loptAction := loptAction::"Post Only";

        end;

        //-- Update the No. Series if the user has not changed the document number
        if lcodInitDocNo = lcodDocNo then
            lcduNoSeriesMgt.SaveNoSeries;

        precRebateLedgEntry.SetCurrentKey("Post-to Customer No.", "Rebate Code");

        precRebateLedgEntry.SetRange("Post-to Customer No.", pcodCustNo);
        precRebateLedgEntry.SetRange("Rebate Code");

        if precRebateLedgEntry.Find('-') then begin
            if loptAction = loptAction::"Post and Create Refund" then begin
                //-- Lock customer ledger to ensure we get the correct application(s)

                // - deleted code

            end;

            if GuiAllowed then begin
                ldlgWindow.Open(lText001);
            end;

            lintCount := precRebateLedgEntry.Count;
            lintCounter := 0;

            repeat
                lintCounter += 1;
                if GuiAllowed then begin
                    ldlgWindow.Update(1, lintCounter);
                    ldlgWindow.Update(2, Round(lintCounter / lintCount) * 10000);
                end;

                //-- Create and post rebates to the customer account
                lrecCurrency.InitRoundingPrecision;

                lrecRebateHeader.Get(precRebateLedgEntry."Rebate Code");

                //<ENRE1.00>
                lrecRebateHeader.TestField(Blocked, false);
                //</ENRE1.00>
                Error('Accure');
                if Round(-(precRebateLedgEntry."Amount (LCY)"), lrecCurrency."Amount Rounding Precision") <> 0 then begin
                    precRebateLedgEntry.TestField("Post-to Customer No.");

                    lrecGenJnlLine.Init;

                    //-- Avoid having to turn on Direct Posting
                    lrecGenJnlLine."System-Created Entry" := true;

                    lrecGenJnlLine."Posting Date" := ldtePostingDate;
                    lrecGenJnlLine."Document No." := lcodDocNo;

                    lrecGenJnlLine."Account Type" := lrecGenJnlLine."Account Type"::"G/L Account";
                    lrecGenJnlLine."Account No." := lrecRebateHeader."Offset G/L Account No.";

                    lrecGenJnlLine."Bal. Account Type" := lrecGenJnlLine."Bal. Account Type"::Customer;
                    lrecGenJnlLine."Bal. Account No." := precRebateLedgEntry."Post-to Customer No.";

                    lrecGenJnlLine.Description := precRebateLedgEntry."Rebate Description";

                    lrecGenJnlLine."Rebate Code ELA" := precRebateLedgEntry."Rebate Code";
                    lrecGenJnlLine."Rebate Source Type ELA" := precRebateLedgEntry."Source Type";
                    lrecGenJnlLine."Rebate Source No. ELA" := precRebateLedgEntry."Source No.";
                    lrecGenJnlLine."Rebate Source Line No. ELA" := precRebateLedgEntry."Source Line No.";
                    lrecGenJnlLine."Rebate Document No. ELA" := precRebateLedgEntry."Rebate Document No.";
                    lrecGenJnlLine."Posted Rebate Entry No. ELA" := precRebateLedgEntry."Entry No.";

                    lrecGenJnlLine."Rebate Accrual Customer No." := precRebateLedgEntry."Post-to Customer No.";

                    lrecGenJnlLine.Validate("Rebate Customer No. ELA", precRebateLedgEntry."Sell-to Customer No.");
                    lrecGenJnlLine.Validate("Rebate Item No. ELA", precRebateLedgEntry."Item No.");

                    lrecGenJnlLine."Source Code" := lrecSourceCodeSetup.Sales;

                    lrecGenJnlLine."Bill-to/Pay-to No." := precRebateLedgEntry."Post-to Customer No.";
                    lrecGenJnlLine."Ship-to/Order Address Code" := precRebateLedgEntry."Ship-to Code";
                    lrecGenJnlLine."Sell-to/Buy-from No." := precRebateLedgEntry."Sell-to Customer No.";


                    //-- Do not reverse the amounts like the "normal" rebate posting does since we are moving amounts
                    //--  from the GL Account to the customer account
                    if precRebateLedgEntry."Amount (DOC)" = 0 then begin
                        lrecGenJnlLine.Validate("Currency Code", '');  //-- use LCY
                        lrecGenJnlLine.Validate(Amount, precRebateLedgEntry."Amount (LCY)");
                    end else begin
                        //-- Post in document currency (eg. customer's currency)
                        //<ENRE1.00>
                        lrecGenJnlLine.Validate("Currency Code", precRebateLedgEntry."Currency Code (DOC)");
                        //</ENRE1.00>
                        lrecGenJnlLine.Validate(Amount, precRebateLedgEntry."Amount (DOC)");
                    end;

                    //<ENRE1.00>
                    if ((precRebateLedgEntry."Job No." <> '') and (precRebateLedgEntry."Job Task No." <> '')) then begin
                        if not lblnPromoJobSourceSetupCheck then
                            if ((lrecSourceCodeSetup."Job G/L Journal" = '') or (lrecSourceCodeSetup."Job G/L WIP" = '')) then
                                Error(lText003);
                        lblnPromoJobSourceSetupCheck := true;
                        lrecGenJnlLine."System-Created Entry" := false;
                        lrecGenJnlLine.Validate(lrecGenJnlLine."Job No.", precRebateLedgEntry."Job No.");
                        lrecGenJnlLine.Validate(lrecGenJnlLine."Job Task No.", precRebateLedgEntry."Job Task No.");
                        lrecGenJnlLine.Validate(lrecGenJnlLine."Job Quantity", 1);
                    end;
                    //</ENRE1.00>

                    lrecGenJnlLine."Shortcut Dimension 1 Code" := '';
                    lrecGenJnlLine."Shortcut Dimension 2 Code" := '';

                    lrecGLEntry.SetRange("G/L Account No.", lrecGenJnlLine."Account No.");
                    lrecGLEntry.SetRange("Posted Rebate Entry No. ELA", precRebateLedgEntry."Entry No.");

                    if not lrecGLEntry.FindFirst then
                        Error(lText000, precRebateLedgEntry."Entry No.", lrecGenJnlLine."Account No.");

                    lrecGenJnlLine."Dimension Set ID" := lrecGLEntry."Dimension Set ID";

                    DimMgt.UpdateGlobalDimFromDimSetID(lrecGenJnlLine."Dimension Set ID",
                      lrecGenJnlLine."Shortcut Dimension 1 Code", lrecGenJnlLine."Shortcut Dimension 2 Code");

                    lcduGenJnlPostLine.RunWithCheck(lrecGenJnlLine);

                    lrecRebateLedgEntry.Get(precRebateLedgEntry."Entry No.");
                    lrecRebateLedgEntry."Posted To Customer" := true;
                    lrecRebateLedgEntry.Modify;

                    if loptAction = loptAction::"Post and Create Refund" then begin
                        lrecCustLedgEntry.FindLast;

                        lrecTEMPCustLedgEntry.Init;
                        lrecTEMPCustLedgEntry."Entry No." := lrecCustLedgEntry."Entry No.";
                        lrecTEMPCustLedgEntry.Insert;
                    end;
                end else begin
                    lrecRebateLedgEntry.Get(precRebateLedgEntry."Entry No.");
                    lrecRebateLedgEntry."Posted To Customer" := true;
                    lrecRebateLedgEntry."Paid to Customer" := true;   //-- mark as paid since it equates to ZERO
                    lrecRebateLedgEntry.Modify;
                end;
            until precRebateLedgEntry.Next = 0;

            if GuiAllowed then
                ldlgWindow.Close;

            if loptAction = loptAction::"Post and Create Refund" then begin
                if lrecTEMPCustLedgEntry.FindSet then begin
                    //-- Create a sales journal of type Refund and apply it to the customer ledger entries that we created above
                    repeat
                        lrecCustLedgEntry.Get(lrecTEMPCustLedgEntry."Entry No.");
                        lrecCustLedgEntry.CalcFields("Remaining Amount");

                        if lrecCustLedgEntry."Remaining Amount" <> 0 then begin
                            lrecCustLedgEntry."Applies-to ID" := lcodDocNo;
                            lrecCustLedgEntry."Amount to Apply" := lrecCustLedgEntry."Remaining Amount";

                            lrecCustLedgEntry.Modify;

                            ldecAmount += -lrecCustLedgEntry."Remaining Amount";
                        end;
                    until lrecTEMPCustLedgEntry.Next = 0;

                    lrecSalesSetup.TestField("Rbt Refund Jnl. Template ELA");
                    lrecSalesSetup.TestField("Rbt Refund Journal Batch ELA");

                    lrecJnlBatch.Get(lrecSalesSetup."Rbt Refund Jnl. Template ELA", lrecSalesSetup."Rbt Refund Journal Batch ELA");
                    lrecJnlBatch.TestField("No. Series", '');

                    lrecGenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Line No.");

                    lrecGenJnlLine.SetRange("Journal Template Name", lrecSalesSetup."Rbt Refund Jnl. Template ELA");
                    lrecGenJnlLine.SetRange("Journal Batch Name", lrecSalesSetup."Rbt Refund Journal Batch ELA");
                    lrecGenJnlLine.SetRange("Line No.");

                    lrecGenJnlLine.LockTable;

                    if lrecGenJnlLine.FindLast then
                        lintLineNo := lrecGenJnlLine."Line No."
                    else
                        lintLineNo := 0;

                    lrecGenJnlLine.Init;

                    lrecGenJnlLine."Journal Template Name" := lrecSalesSetup."Rbt Refund Jnl. Template ELA";
                    lrecGenJnlLine."Journal Batch Name" := lrecSalesSetup."Rbt Refund Journal Batch ELA";
                    lrecGenJnlLine."Line No." := lintLineNo + 10000;

                    lrecGenJnlLine.Insert(true);

                    lrecGenJnlLine.Validate("Posting Date", ldtePostingDate);
                    lrecGenJnlLine.Validate("Document Type", lrecGenJnlLine."Document Type"::Refund);
                    lrecGenJnlLine.Validate("Document No.", lcodDocNo);

                    lrecGenJnlLine.Validate("Account Type", lrecGenJnlLine."Account Type"::Customer);
                    lrecGenJnlLine.Validate("Account No.", precRebateLedgEntry."Post-to Customer No.");

                    lrecGenJnlLine.Validate("Bal. Account Type", lrecJnlBatch."Bal. Account Type");
                    lrecGenJnlLine.Validate("Bal. Account No.", lrecJnlBatch."Bal. Account No.");

                    lrecGenJnlLine.Validate("Reason Code", lrecJnlBatch."Reason Code");

                    lrecGenJnlLine."Source Code" := lrecSourceCodeSetup."Payment Journal";

                    lrecGenJnlLine.Validate("Applies-to ID", lcodDocNo);

                    //<ENRE1.00>
                    lrecGenJnlLine.Validate("Currency Code", lrecCustLedgEntry."Currency Code");
                    //</ENRE1.00>

                    lrecGenJnlLine.Validate(Amount, ldecAmount);

                    lrecGenJnlLine."Bank Payment Type" := lrecGenJnlLine."Bank Payment Type"::"Computer Check";

                    lrecGenJnlLine.Modify(true);

                    lrecGenJnlLine.ValidateApplyRequirements(lrecGenJnlLine);

                    if GuiAllowed then
                        Message(lText002,
                                lrecGenJnlLine."Line No.",
                                lrecGenJnlLine."Journal Batch Name");
                end;
            end;
        end;
        //</ENRE1.00>
    end;


    procedure SkipDialogMode(pbln: Boolean)
    begin
        //<ENRE1.00>
        gblnUseDefaultPostingValues := pbln;
        //</ENRE1.00>
    end;


    procedure CalcSalesDocLineRebate(prrfHeader: RecordRef; prrfLine: RecordRef; pblnPeriodicCalc: Boolean; pblnForceDocRebatesOnly: Boolean; pblnForceCreditApplyToCheck: Boolean)
    var
        lrrfLine: RecordRef;
        lfrfHdrDocType: FieldRef;
        lfrfHdrDocNo: FieldRef;
        lfrfLineDocType: FieldRef;
        lfrfLineDocNo: FieldRef;
        lfrfLineDocLineNo: FieldRef;
        lfrfLineDocLineNoValue: FieldRef;
        lfrfLineType: FieldRef;
        lfrfLineQtyInvoiced: FieldRef;
        lfrfBypassCalc: FieldRef;
        lintTableNo: Integer;
        lrecTempRebateEntry: Record "Rebate Entry ELA" temporary;
        lfrfFieldRef: FieldRef;
        lfrfFieldRef2: FieldRef;
        lfrfFieldRef3: FieldRef;
    begin
        //<ENRE1.00>
        //-- Delete all existing rebate entry for line
        DeleteRebateEntry(prrfLine);

        lintTableNo := prrfHeader.Number;
        case lintTableNo of
            36:
                begin
                    lfrfHdrDocType := prrfHeader.Field(1);
                    //<ENRE1.00>
                    grecSalesSetup.Get;
                    if grecSalesSetup."Frc Appl On SalesReturns ELA" then begin
                        //</ENRE1.00>
                        //-- Credit Memo -> Applies-to Doc. Type must be invoice and Applies-to Doc. No. not be blank
                        if pblnForceCreditApplyToCheck = true then begin
                            if (Format(lfrfHdrDocType.Value) = '3') then begin
                                //<ENRE1.00>
                                lfrfFieldRef := prrfHeader.Field(52);
                                lfrfFieldRef2 := prrfHeader.Field(53);

                                if not ((Format(lfrfFieldRef.Value) = '2') and (Format(lfrfFieldRef2.Value) <> '')) then begin
                                    exit;
                                end;
                                //</ENRE1.00>
                            end;
                        end;
                    end; //<ENRE1.00>
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lfrfBypassCalc := prrfHeader.Field(14229403);

                    lfrfLineDocLineNoValue := prrfLine.Field(4);

                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;

                    lrrfLine.Open(37);
                    lfrfLineDocType := lrrfLine.Field(1);
                    lfrfLineDocType.SetFilter(Format(lfrfHdrDocType.Value));
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    lfrfLineDocLineNo := lrrfLine.Field(4);
                    lfrfLineDocLineNo.SetFilter(Format(lfrfLineDocLineNoValue.Value));

                    //-- no need to recalculate lines that have already been invoiced
                    //-- periodic routine will pick up the posted rebate and will apply any differences to the invoice
                    lfrfLineQtyInvoiced := lrrfLine.Field(61);
                    //<ENRE1.00> - deleted code
                end;
            112:
                begin
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lfrfLineDocLineNoValue := prrfLine.Field(4);

                    lrrfLine.Open(113);
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    lfrfLineDocLineNo := lrrfLine.Field(4);
                    lfrfLineDocLineNo.SetFilter(Format(lfrfLineDocLineNoValue.Value));

                    lfrfBypassCalc := prrfHeader.Field(14229420);

                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;
                end;
            114:
                begin
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lfrfLineDocLineNoValue := prrfLine.Field(4);
                    //<ENRE1.00>
                    grecSalesSetup.Get;
                    if grecSalesSetup."Frc Appl On SalesReturns ELA" then begin
                        //</ENRE1.00>

                        //-- Posted Cr. Memo -> must have Return Order No. or Applies-to Doc. Type must be invoice and Applies-to Doc. No. not be blank
                        if pblnForceCreditApplyToCheck = true then begin
                            //<ENRE1.00>
                            lfrfFieldRef := prrfHeader.Field(6601);
                            lfrfFieldRef2 := prrfHeader.Field(52);
                            lfrfFieldRef3 := prrfHeader.Field(53);

                            if not ((Format(lfrfFieldRef.Value) <> '') or
                              ((Format(lfrfFieldRef2.Value) = '2') and (Format(lfrfFieldRef3.Value) <> ''))) then begin
                                exit;
                            end;
                            //</ENRE1.00>
                        end;
                    end; //<ENRE1.00>
                    lrrfLine.Open(115);
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    lfrfLineDocLineNo := lrrfLine.Field(4);
                    lfrfLineDocLineNo.SetFilter(Format(lfrfLineDocLineNoValue.Value));

                    lfrfBypassCalc := prrfHeader.Field(14229420);

                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;
                end;
            else begin
                    Error('');
                end;
        end;

        if pblnForceDocRebatesOnly then
            //<ENRE1.00>
            grecRebateHeaderFilter.SetFilter("Rebate Type", '%1|%2|%3',
                                           grecRebateHeaderFilter."Rebate Type"::"Off-Invoice",
                                           grecRebateHeaderFilter."Rebate Type"::Everyday,
                                           grecRebateHeaderFilter."Rebate Type"::Commodity);
        //</ENRE1.00>
        if lrrfLine.Find('-') then begin
            CalcRebate(lrrfLine, pblnPeriodicCalc, lrecTempRebateEntry);
        end;
        //</ENRE1.00>
    end;


    procedure CalcAmount(var precRLE: Record "Rebate Ledger Entry ELA"; pblnIncludeTax: Boolean): Decimal
    var
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
        lrecRebateLedgerEntry: Record "Rebate Ledger Entry ELA";
    begin
        //<ENRE1.00>
        case precRLE."Source Type" of
            precRLE."Source Type"::"Posted Invoice", precRLE."Source Type"::"Posted Cr. Memo":
                begin
                    case precRLE."Source Type" of
                        precRLE."Source Type"::"Posted Invoice":
                            begin
                                //<ENRE1.00>
                                lrecSalesInvLine.SetRange("Document No.", precRLE."Source No.");
                                if pblnIncludeTax then begin
                                    lrecSalesInvLine.CalcSums("Amount Including VAT");
                                    exit(lrecSalesInvLine."Amount Including VAT");
                                end else begin
                                    lrecSalesInvLine.CalcSums(Amount);
                                    exit(lrecSalesInvLine.Amount);
                                end;
                                //</ENRE1.00>

                            end;
                        precRLE."Source Type"::"Posted Cr. Memo":
                            begin
                                //<ENRE1.00>
                                lrecSalesCrMemoLine.SetRange("Document No.", precRLE."Source No.");
                                if pblnIncludeTax then begin
                                    lrecSalesCrMemoLine.CalcSums("Amount Including VAT");
                                    exit(lrecSalesCrMemoLine."Amount Including VAT");
                                end else begin
                                    lrecSalesCrMemoLine.CalcSums(Amount);
                                    exit(lrecSalesCrMemoLine.Amount);
                                end;
                                //</ENRE1.00>
                            end;
                    end;
                end;
            else
                exit(0);
        end;
        //</ENRE1.00>
    end;


    procedure CalcRebateAmount(var precRLE: Record "Rebate Ledger Entry ELA"; poptAmountType: Option LCY,RBT,DOC): Decimal
    var
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
        lrecRebateLedgerEntry: Record "Rebate Ledger Entry ELA";
    begin
        //<ENRE1.00>
        case precRLE."Source Type" of
            precRLE."Source Type"::"Posted Invoice", precRLE."Source Type"::"Posted Cr. Memo":
                begin
                    lrecRebateLedgerEntry.SetCurrentKey("Source Type", "Source No.", "Source Line No.",
                                          "Post-to Customer No.", "Rebate Code", "Posted To G/L", "Posted To Customer", "G/L Posting Only");
                    lrecRebateLedgerEntry.SetRange("Source Type", precRLE."Source Type");
                    lrecRebateLedgerEntry.SetRange("Source No.", precRLE."Source No.");
                    //<ENRE1.00> - deleted code
                    lrecRebateLedgerEntry.SetRange("Post-to Customer No.", precRLE."Post-to Customer No.");
                    lrecRebateLedgerEntry.SetRange("Rebate Code", precRLE."Rebate Code");
                    lrecRebateLedgerEntry.SetRange("Posted To G/L", true);
                    lrecRebateLedgerEntry.SetRange("Posted To Customer", false);
                    lrecRebateLedgerEntry.SetRange("G/L Posting Only", true);
                    lrecRebateLedgerEntry.CalcSums(lrecRebateLedgerEntry."Amount (LCY)", lrecRebateLedgerEntry."Amount (RBT)",
                                                    lrecRebateLedgerEntry."Amount (DOC)");
                    case poptAmountType of
                        poptAmountType::LCY:
                            begin
                                exit(lrecRebateLedgerEntry."Amount (LCY)");
                            end;
                        poptAmountType::RBT:
                            begin
                                exit(lrecRebateLedgerEntry."Amount (RBT)");
                            end;
                        poptAmountType::DOC:
                            begin
                                exit(lrecRebateLedgerEntry."Amount (DOC)");
                            end;
                    end;
                end;
            else
                exit(0);
        end;
        //</ENRE1.00>
    end;


    procedure CreateRebateAdjustment(var precRLE: Record "Rebate Ledger Entry ELA")
    var
        lrecRebateJnlLine: Record "Rebate Journal Line ELA";
        lfrmCreateRebateAdj: Page "Create Rebate Adjustment ELA";
        ldecAdjustmentAmount: Decimal;
        lcodReasonCode: Code[10];
        ltxtUser: Text[65];
        lcodToBatchName: Code[10];
        lText000: Label 'Default';
        lrecRebateBatch: Record "Rebate Batch ELA";
        lintLineNo: Integer;
        lText001: Label 'Adjustment';
        lText002: Label 'Adjustment Amount cannot be 0.';
        lText003: Label 'Adjustments cannot be made for entries where %1 is %2';
    begin
        //<ENRE1.00>
        case precRLE."Source Type" of
            precRLE."Source Type"::"Posted Invoice", precRLE."Source Type"::"Posted Cr. Memo":
                begin

                    ltxtUser := UpperCase(UserId); // Uppercase in case of Windows Login

                    if ltxtUser <> '' then begin
                        lcodToBatchName := CopyStr(ltxtUser, 1, MaxStrLen(lrecRebateJnlLine."Rebate Batch Name"))
                    end else begin
                        lcodToBatchName := lText000;
                    end;

                    if not lrecRebateBatch.Get(lcodToBatchName) then begin
                        lrecRebateBatch.Name := lcodToBatchName;
                        lrecRebateBatch.Description := lcodToBatchName;
                        lrecRebateBatch.Insert(true);
                    end;

                    lrecRebateJnlLine.SetRange("Rebate Batch Name", lcodToBatchName);
                    if lrecRebateJnlLine.FindLast then begin
                        lintLineNo := lrecRebateJnlLine."Line No." + 10000;
                    end else begin
                        lintLineNo := 10000;
                    end;
                    Commit;

                    lrecRebateJnlLine.SetRange("Rebate Batch Name");
                    lrecRebateJnlLine.Reset;
                    Clear(lrecRebateJnlLine);

                    Clear(lfrmCreateRebateAdj);
                    if lfrmCreateRebateAdj.RunModal = ACTION::Yes then begin
                        lfrmCreateRebateAdj.ReturnPostingInfo(ldecAdjustmentAmount, lcodReasonCode);
                        if ldecAdjustmentAmount = 0 then begin
                            Error(lText002);
                        end;
                        lrecRebateJnlLine."Rebate Batch Name" := lcodToBatchName;
                        lrecRebateJnlLine."Line No." := lintLineNo;
                        lrecRebateJnlLine."Document Type" := lrecRebateJnlLine."Document Type"::Adjustment;
                        lrecRebateJnlLine."Document No." := lText001;
                        lrecRebateJnlLine."Applies-To Customer No." := precRLE."Post-to Customer No.";
                        case precRLE."Source Type" of
                            precRLE."Source Type"::"Posted Invoice":
                                begin
                                    lrecRebateJnlLine."Applies-To Source Type" := lrecRebateJnlLine."Applies-To Source Type"::"Posted Sales Invoice";
                                end;
                            precRLE."Source Type"::"Posted Cr. Memo":
                                begin
                                    lrecRebateJnlLine."Applies-To Source Type" := lrecRebateJnlLine."Applies-To Source Type"::"Posted Sales Cr. Memo";
                                end;
                        end;

                        lrecRebateJnlLine."Applies-To Source No." := precRLE."Source No.";
                        lrecRebateJnlLine."Applies-To Source Line No." := precRLE."Source Line No.";
                        lrecRebateJnlLine."Rebate Code" := precRLE."Rebate Code";
                        lrecRebateJnlLine."Posting Date" := WorkDate;
                        lrecRebateJnlLine."Amount (LCY)" := ldecAdjustmentAmount;
                        lrecRebateJnlLine."Reason Code" := lcodReasonCode;
                        lrecRebateJnlLine.Adjustment := true;
                        lrecRebateJnlLine.Insert;

                        lrecRebateJnlLine.SetFilter("Rebate Batch Name", '%1', lcodToBatchName);
                        lrecRebateJnlLine.SetFilter("Line No.", '%1', lintLineNo);
                        CODEUNIT.Run(14229412, lrecRebateJnlLine);
                    end;
                end else begin
                            Error(lText003, precRLE.FieldCaption("Source Type"), Format(precRLE."Source Type"));
                        end;
        end;

        //</ENRE1.00>
    end;


    procedure BypassPurchRebates(pblnBypassPurchRebates: Boolean)
    begin
        //<ENRE1.00>
        gblnBypassPurchRebates := pblnBypassPurchRebates;
        //</ENRE1.00>
    end;


    procedure CalcOpenCommodityUsed(precCommAllLine: Record "Commodity Allocation Line ELA"; pintTableNo: Integer; poptSourceType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor; pcodSourceNo: Code[20]; pintSourceLineNo: Integer): Decimal
    var
        lrecCommodityEntry: Record "Commodity Entry ELA";
        ldecOpenQty: Decimal;
    begin
        //<ENRE1.00>

        Clear(ldecOpenQty);
        lrecCommodityEntry.SetRange("Recipient Agency No.", precCommAllLine."Recipient Agency No.");
        lrecCommodityEntry.SetRange("Vendor No.", precCommAllLine."Vendor No.");
        lrecCommodityEntry.SetRange("Commodity No.", precCommAllLine."Commodity No.");
        lrecCommodityEntry.SetRange("Posting Date", precCommAllLine."Starting Date", precCommAllLine."Ending Date");
        lrecCommodityEntry.SetFilter("Source Type", '<>%1', lrecCommodityEntry."Source Type"::"Credit Memo");
        if lrecCommodityEntry.FindSet then begin
            repeat
                if pcodSourceNo <> lrecCommodityEntry."Source No." then begin
                    lrecCommodityEntry.CalcFields("Quantity Posted");
                    ldecOpenQty += lrecCommodityEntry.Quantity - lrecCommodityEntry."Quantity Posted";
                end;
            until lrecCommodityEntry.Next = 0;
        end;
        exit(ldecOpenQty);
        //</ENRE1.00>
    end;


    procedure CalcCurrentDocCommodityUsed(precCommAllLine: Record "Commodity Allocation Line ELA"; pintTableNo: Integer; poptSourceType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor; pcodSourceNo: Code[20]; pintSourceLineNo: Integer): Decimal
    var
        ldecOpenQty: Decimal;
    begin
        //<ENRE1.00>
        grecCommodityLedgerTemp.SetRange("Posting Date", gdteOrderDate);
        grecCommodityLedgerTemp.SetRange("Commodity No.", precCommAllLine."Commodity No.");
        grecCommodityLedgerTemp.SetRange("Vendor No.", precCommAllLine."Vendor No.");
        grecCommodityLedgerTemp.SetRange("Recipient Agency No.", precCommAllLine."Recipient Agency No.");
        grecCommodityLedgerTemp.SetRange("Source No.", pcodSourceNo);
        if grecCommodityLedgerTemp.FindSet then begin
            repeat
                ldecOpenQty += grecCommodityLedgerTemp.Quantity;
            until grecCommodityLedgerTemp.Next = 0;
        end;
        exit(ldecOpenQty);
        //</ENRE1.00>
    end;

    [IntegrationEvent(false, false)]
    local procedure rdOnAfterInsertTempRebateLines(var pTempRebateLine: Record "Rebate Line ELA" temporary; var pTempRebateHeader: Record "Rebate Header ELA" temporary; pOrderDate: Date)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure rdOnBeforeFilterLines(var prrfHeader: RecordRef; var prrfLine: RecordRef)
    begin
    end;
}

