codeunit 14229408 "Purchase Rebate Management ELA"
{


    // ENRE1.00 2021-08-26 AJ
    //    - New Codeunit
    // 
    // 
    //    - Functions Modified
    //              - CalcRebate
    //              - CalcRebateFromRebateCode
    //              - CreateRebateEntry
    //              - CalcPurchDocRebate
    //            - New Functions
    //              - CalcGuranteedCostDealRebate
    //              - DeleteGCDRebateEntry
    //              - DeleteGCDRebateEntryLines
    //              - GuaranteedCostRebateCalc
    // 
    //    - Below Functions Modified
    //              - CalcPurchDocRebate
    //              - CalcPurchDocLineRebate
    //              - CalcGuranteedCostDealRebate
    // 
    // 
    //    - New Functions
    //              - CalcRebateFromRebateCode
    // 
    // 
    // 
    //     - change ::"Guaranteed Cost Deal" from a "Rebate Type" to a "Calculation Basis"
    //       (replace "Rebate Type"::"Guaranteed Cost Deal" option with "Rebate Type"::"Sales-Based")
    //     - rename CalcGuranteedCostDealRebate to CalcSalesBasedPurchRebate
    //     - rename GuaranteedCostRebateCalc to SetSalesBasedRebateMode
    //     - rename DeleteGCDRebateEntry to DeleteSalesBasedRebateEntry
    //     - rename DeleteGCDRebateEntryLines to DeleteSBRebateEntryLines
    // 
    // 
    //    - bug fix: Guaranteed Cost Deals now accrue NEGATIVE rebates as well
    // 
    // 
    //    - Sales-Based Guaranteed Cost Deals now have a Guaranteed Cost Basis:
    //               Last Receipt, Adj. Document Cost, or User-Defined Calculation
    // 
    // 
    //    - create a ZERO value "Guaranteed Cost Basis"::"Last Receipt" Sales-Based
    //              Guaranteed Cost Rebate if no receipt ledger entries are found
    //              (Had been creating rebates for the full Guaranteed Cost.)
    // 
    // 
    //    - modified code to create sales profit modifier records for "Sales Based" purchase rebates and Purchase Rebates
    //              marked as "Sales Profit Modifier"
    //            - filter fixes
    // 
    // 
    //    - Sales Rec get added;  grecPurchSetup."Rebate Date Source fix
    // 
    // 
    //    - new function CreateRebateAdjustment
    // 
    // 
    //    - Modified Function
    //              - CalcSalesBasedPurchRebate
    //   - add Variable Weight support to $/Unit Rebate calculation

    Permissions = TableData "Cust. Ledger Entry" = rimd;

    trigger OnRun()
    begin
    end;

    var
        grecPurchSetup: Record "Purchases & Payables Setup";
        gRecPurchRebateHeaderFilter: Record "Purchase Rebate Header ELA";
        gblnUseDefaultPostingValues: Boolean;
        grecSalesSetup: Record "Sales & Receivables Setup";
        gblnSalesBasedRebateMode: Boolean;
        grecGLSetup: Record "General Ledger Setup";


    procedure CalcRebate(prrfLine: RecordRef; pblnPeriodicCalc: Boolean; var precTempRebateEntry: Record "Rebate Entry ELA")
    var
        lrecRebateLine: Record "Purchase Rebate Line ELA";
        lrecTempRebateLine: Record "Purchase Rebate Line ELA" temporary;
        lrecVendor: Record Vendor;
        lrecItem: Record Item;
        lcodLastRebate: Code[20];
        lrecPurchHeader: Record "Purchase Header";
        lcodSalesperson: Code[20];
        lrecRebate: Record "Purchase Rebate Header ELA";
        lrecTempRebate: Record "Purchase Rebate Header ELA" temporary;
        lblnIsExclusion: Boolean;
        lblnIsApplicableItem: Boolean;
        lRecPurchRebateDetailTEMP: Record "Purchase Rebate Line ELA" temporary;
        lblnOverrideItemProperties: Boolean;
        lblnFoundVendOverride: Boolean;
        lblnFoundItemOverride: Boolean;
        lrecGLSetup: Record "General Ledger Setup";
        lrecDimValue: Record "Dimension Value";
        lblnIsApplicableEntity: Boolean;
        lblnFoundEntityOverride: Boolean;
        lcodEntity: Code[20];
        lblnFoundHit: Boolean;
        lblnspecificitemsdefined: Boolean;
        lrecPurchInvHeader: Record "Purch. Inv. Header";
        lblnItemGroup: Boolean;
        lblnItemRebateGroup: Boolean;
        lblnItemCategoryCode: Boolean;
        lintTableNo: Integer;
        lfrfDocType: FieldRef;
        lfrfDocNo: FieldRef;
        ltxtFilter: Text[1024];
        lrecPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        lrecReturnShptHdr: Record "Return Shipment Header";
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
        lrecSalesHeader: Record "Sales Header";
        lrecSalesInvHeader: Record "Sales Invoice Header";
        lrecSalesCrMemoHdr: Record "Sales Cr.Memo Header";
        lrecReturnReceiptHdr: Record "Return Receipt Header";
        lrecRebateCust: Record "Purchase Rebate Customer ELA";
        lrecCustomer: Record Customer;
        lrecILE: Record "Item Ledger Entry";
        DimMgt: Codeunit DimensionManagement;
        lrecTempDimSetEntry: Record "Dimension Set Entry" temporary;
        lrecPurchLine: Record "Purchase Line";
        lrecPurchInvLine: Record "Purch. Inv. Line";
        lrecPurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        Clear(ldteOrderDate);

        lblnIsReturnOrder := false;

        grecPurchSetup.Get;
        lrecGLSetup.Get;

        //<ENRE1.00>
        grecSalesSetup.Get;
        //</ENRE1.00>

        lintTableNo := prrfLine.Number;
        lfrfFieldRef := prrfLine.Field(4);
        Evaluate(lintLineNo, Format(lfrfFieldRef.Value));
        case lintTableNo of
            39:
                begin
                    lfrfDocType := prrfLine.Field(1);
                    lfrfDocNo := prrfLine.Field(3);
                    lrecPurchHeader.SetFilter("Document Type", Format(lfrfDocType.Value));
                    lrecPurchHeader.SetFilter("No.", Format(lfrfDocNo.Value));

                    if not lrecPurchHeader.FindFirst then
                        exit;

                    lcodShiptoCode := lrecPurchHeader."Order Address Code";
                    if Format(lfrfDocType.Value) = '3' then begin

                        lfrfFieldRef := prrfLine.Field(6);
                        if Format(lfrfFieldRef.Value) = '' then
                            exit;

                        if lrecPurchHeader."Applies-to Doc. No." = '' then begin
                            case grecPurchSetup."Rebate Date Source ELA" of
                                grecPurchSetup."Rebate Date Source ELA"::"Order Date":
                                    begin
                                        if lrecPurchHeader."Posting Date" = 0D then
                                            exit;
                                        ldteOrderDate := lrecPurchHeader."Posting Date";
                                    end;
                                grecPurchSetup."Rebate Date Source ELA"::"Expected Receipt Date":
                                    begin
                                        if lrecPurchHeader."Expected Receipt Date" <> 0D then
                                            ldteOrderDate := lrecPurchHeader."Expected Receipt Date"
                                        else
                                            if lrecPurchHeader."Posting Date" <> 0D then
                                                ldteOrderDate := lrecPurchHeader."Posting Date"
                                            else
                                                exit;
                                    end;
                            end;
                        end else begin
                            if not lrecPurchInvHeader.Get(lrecPurchHeader."Applies-to Doc. No.") then
                                exit;

                            case grecPurchSetup."Rebate Date Source ELA" of
                                grecPurchSetup."Rebate Date Source ELA"::"Order Date":
                                    begin
                                        if lrecPurchInvHeader."Order Date" = 0D then
                                            exit;

                                        ldteOrderDate := lrecPurchInvHeader."Order Date";
                                    end;
                                grecPurchSetup."Rebate Date Source ELA"::"Expected Receipt Date":
                                    begin
                                        if lrecPurchInvHeader."Expected Receipt Date" <> 0D then
                                            ldteOrderDate := lrecPurchInvHeader."Expected Receipt Date"
                                        else
                                            if lrecPurchInvHeader."Order Date" <> 0D then
                                                ldteOrderDate := lrecPurchInvHeader."Order Date"
                                            else
                                                exit;
                                    end;
                            end;
                        end;
                    end else begin
                        if Format(lfrfDocType.Value) = '5' then begin //Return Order
                            lblnIsReturnOrder := true;
                            lfrfFieldRef := prrfLine.Field(6);
                            if Format(lfrfFieldRef.Value) = '' then begin
                                exit;
                            end;
                        end else begin
                            lfrfFieldRef := prrfLine.Field(5);
                            lfrfFieldRef2 := prrfLine.Field(6);
                            if (Format(lfrfFieldRef.Value) <> '2') and
                               (Format(lfrfFieldRef2.Value) = '') then begin
                                exit;
                            end;
                        end;
                        case grecPurchSetup."Rebate Date Source ELA" of
                            grecPurchSetup."Rebate Date Source ELA"::"Order Date":
                                begin
                                    //<ENRE1.00>
                                    if lrecPurchHeader."Order Date" = 0D then
                                        exit;
                                    //</ENRE1.00>
                                    ldteOrderDate := lrecPurchHeader."Order Date";
                                end;
                            grecPurchSetup."Rebate Date Source ELA"::"Expected Receipt Date":
                                begin
                                    if lrecPurchHeader."Expected Receipt Date" <> 0D then
                                        ldteOrderDate := lrecPurchHeader."Expected Receipt Date"
                                    else
                                        if lrecPurchHeader."Order Date" <> 0D then
                                            ldteOrderDate := lrecPurchHeader."Order Date"
                                        else
                                            exit;
                                end;
                        end;
                    end;
                end;
            123:
                begin
                    lfrfRefItemNo := prrfLine.Field(6);
                    lfrfFieldRef := prrfLine.Field(5);
                    if (Format(lfrfFieldRef.Value) <> '2') and
                       (Format(lfrfRefItemNo.Value) = '') then begin
                        exit;
                    end;
                    lfrfDocNo := prrfLine.Field(3);
                    if not lrecPurchInvHeader.Get(lfrfDocNo.Value) then begin
                        exit;
                    end;
                    lcodShiptoCode := lrecPurchInvHeader."Order Address Code";
                    case grecPurchSetup."Rebate Date Source ELA" of
                        grecPurchSetup."Rebate Date Source ELA"::"Order Date":
                            begin
                                ldteOrderDate := lrecPurchInvHeader."Order Date";
                            end;
                        grecPurchSetup."Rebate Date Source ELA"::"Expected Receipt Date":
                            begin
                                if lrecPurchInvHeader."Expected Receipt Date" <> 0D then
                                    ldteOrderDate := lrecPurchInvHeader."Expected Receipt Date"
                                else
                                    if lrecPurchInvHeader."Order Date" <> 0D then
                                        ldteOrderDate := lrecPurchInvHeader."Order Date"
                                    else
                                        exit;
                            end;
                    end;
                end;
            125:
                begin
                    lfrfDocNo := prrfLine.Field(3);
                    if not lrecPurchCrMemoHdr.Get(lfrfDocNo.Value) then begin
                        exit;
                    end else begin
                        lcodShiptoCode := lrecPurchCrMemoHdr."Order Address Code";
                        if lrecPurchCrMemoHdr."Return Order No." <> '' then begin
                            lrecReturnShptHdr.Reset;
                            lrecReturnShptHdr.SetRange("Return Order No.", lrecPurchCrMemoHdr."Return Order No.");
                            if lrecReturnShptHdr.FindFirst then begin
                                case grecPurchSetup."Rebate Date Source ELA" of
                                    grecPurchSetup."Rebate Date Source ELA"::"Order Date":
                                        begin
                                            ldteOrderDate := lrecReturnShptHdr."Posting Date";
                                        end;
                                    grecPurchSetup."Rebate Date Source ELA"::"Expected Receipt Date":
                                        begin
                                            if lrecReturnShptHdr."Expected Receipt Date" <> 0D then
                                                ldteOrderDate := lrecReturnShptHdr."Expected Receipt Date"
                                            else
                                                if lrecReturnShptHdr."Posting Date" <> 0D then
                                                    ldteOrderDate := lrecReturnShptHdr."Posting Date"
                                                else
                                                    exit;
                                        end;
                                end;
                            end;
                        end else begin
                            if lrecPurchCrMemoHdr."Applies-to Doc. No." = '' then begin
                                case grecPurchSetup."Rebate Date Source ELA" of
                                    grecPurchSetup."Rebate Date Source ELA"::"Order Date":
                                        begin
                                            if lrecPurchCrMemoHdr."Posting Date" = 0D then
                                                exit;
                                            ldteOrderDate := lrecPurchCrMemoHdr."Posting Date";
                                        end;
                                    grecPurchSetup."Rebate Date Source ELA"::"Expected Receipt Date":
                                        begin
                                            if lrecPurchCrMemoHdr."Expected Receipt Date" <> 0D then
                                                ldteOrderDate := lrecPurchCrMemoHdr."Expected Receipt Date"
                                            else
                                                if lrecPurchCrMemoHdr."Posting Date" <> 0D then
                                                    ldteOrderDate := lrecPurchCrMemoHdr."Posting Date"
                                                else
                                                    exit;
                                        end;
                                end;
                            end else begin
                                if not lrecPurchInvHeader.Get(lrecPurchCrMemoHdr."Applies-to Doc. No.") then
                                    exit;
                                case grecPurchSetup."Rebate Date Source ELA" of
                                    grecPurchSetup."Rebate Date Source ELA"::"Order Date":
                                        begin
                                            if lrecPurchInvHeader."Order Date" = 0D then
                                                exit;

                                            ldteOrderDate := lrecPurchInvHeader."Order Date";
                                        end;
                                    grecPurchSetup."Rebate Date Source ELA"::"Expected Receipt Date":
                                        begin
                                            if lrecPurchInvHeader."Expected Receipt Date" <> 0D then
                                                ldteOrderDate := lrecPurchInvHeader."Expected Receipt Date"
                                            else
                                                if lrecPurchInvHeader."Order Date" <> 0D then
                                                    ldteOrderDate := lrecPurchInvHeader."Order Date"
                                                else
                                                    exit;
                                        end;
                                end;
                            end;
                        end;
                    end;
                end;
            //<ENRE1.00>
            DATABASE::"Sales Line":
                begin
                    lfrfDocType := prrfLine.Field(1);
                    lfrfDocNo := prrfLine.Field(3);
                    lrecSalesHeader.SetFilter("Document Type", Format(lfrfDocType.Value));
                    lrecSalesHeader.SetFilter("No.", Format(lfrfDocNo.Value));
                    if not lrecSalesHeader.FindFirst then
                        exit;
                    lcodShiptoCode := lrecSalesHeader."Ship-to Code";
                    lcodSalesperson := lrecSalesHeader."Salesperson Code";
                    if Format(lfrfDocType.Value) = '3' then begin //Cr. Memo
                        lfrfFieldRef := prrfLine.Field(14228851); //02
                        if Format(lfrfFieldRef.Value) = '' then
                            exit;
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
                    end else begin
                        if Format(lfrfDocType.Value) = '5' then begin //Return Order
                            lblnIsReturnOrder := true;
                            lfrfFieldRef := prrfLine.Field(14228851);
                            if Format(lfrfFieldRef.Value) = '' then begin
                                exit;
                            end;
                        end else begin
                            lfrfFieldRef := prrfLine.Field(5);
                            lfrfFieldRef2 := prrfLine.Field(14228851);
                            if (Format(lfrfFieldRef.Value) <> '2') and
                               (Format(lfrfFieldRef2.Value) = '') then begin
                                exit;
                            end;
                        end;
                        case grecSalesSetup."Rebate Date Source ELA" of
                            grecSalesSetup."Rebate Date Source ELA"::"Order Date":
                                begin
                                    ldteOrderDate := lrecSalesHeader."Order Date";
                                end;
                            grecSalesSetup."Rebate Date Source ELA"::"Shipment Date":
                                begin
                                    ldteOrderDate := lrecSalesHeader."Shipment Date";
                                end;
                        end;
                    end;
                end;
            DATABASE::"Sales Invoice Line":
                begin             //Sales Invoice Line
                    lfrfRefItemNo := prrfLine.Field(14228851);
                    lfrfFieldRef := prrfLine.Field(5);
                    lfrfFieldRef2 := prrfLine.Field(14228851);
                    if (Format(lfrfFieldRef.Value) <> '2') and
                       (Format(lfrfFieldRef2.Value) = '') then begin
                        exit;
                    end;
                    lfrfDocNo := prrfLine.Field(3);
                    if not lrecSalesInvHeader.Get(lfrfDocNo.Value) then begin
                        exit;
                    end;
                    lcodShiptoCode := lrecSalesInvHeader."Ship-to Code";
                    lcodSalesperson := lrecSalesInvHeader."Salesperson Code";
                    case grecSalesSetup."Rebate Date Source ELA" of
                        grecSalesSetup."Rebate Date Source ELA"::"Order Date":
                            begin
                                ldteOrderDate := lrecSalesInvHeader."Order Date";
                            end;
                        grecSalesSetup."Rebate Date Source ELA"::"Shipment Date":
                            begin
                                ldteOrderDate := lrecSalesInvHeader."Shipment Date";
                            end;
                    end;
                end;
            DATABASE::"Sales Cr.Memo Line":
                begin             //Sales Cr. Memo Line
                    lfrfDocNo := prrfLine.Field(3);
                    if not lrecSalesCrMemoHdr.Get(lfrfDocNo.Value) then begin
                        exit;
                    end else begin
                        lcodShiptoCode := lrecSalesCrMemoHdr."Ship-to Code";
                        lcodSalesperson := lrecSalesCrMemoHdr."Salesperson Code";
                        if lrecSalesCrMemoHdr."Return Order No." <> '' then begin
                            lrecReturnReceiptHdr.Reset;
                            lrecReturnReceiptHdr.SetRange("Return Order No.", lrecSalesCrMemoHdr."Return Order No.");
                            if lrecReturnReceiptHdr.FindFirst then begin
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
                            end;
                        end else begin
                            //-- If not from a return order, use the Order Date field if not blank
                            if lrecSalesCrMemoHdr."Applies-to Doc. No." = '' then begin
                                case grecSalesSetup."Rebate Date Source ELA" of
                                    grecSalesSetup."Rebate Date Source ELA"::"Order Date":
                                        begin
                                            if lrecSalesCrMemoHdr."Order Date ELA" = 0D then
                                                exit;

                                            ldteOrderDate := lrecSalesCrMemoHdr."Order Date ELA";
                                        end;
                                    grecSalesSetup."Rebate Date Source ELA"::"Shipment Date":
                                        begin
                                            if lrecSalesCrMemoHdr."Shipment Date" = 0D then
                                                exit;

                                            ldteOrderDate := lrecSalesCrMemoHdr."Shipment Date";
                                        end;
                                end;
                            end else begin
                                if not lrecSalesInvHeader.Get(lrecSalesCrMemoHdr."Applies-to Doc. No.") then
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
                        end;
                    end;
                end;
        //</ENRE1.00>
        end;

        if lblnIsReturnOrder then begin
            //<ENRE1.00>
            if ((lintTableNo = DATABASE::"Sales Line") or (lintTableNo = DATABASE::"Sales Invoice Line") or
                (lintTableNo = DATABASE::"Sales Cr.Memo Line")) then
                lfrfFieldRef := prrfLine.Field(23)
            else
                //<ENRE1.00>
                lfrfFieldRef := prrfLine.Field(22);
            if Format(lfrfFieldRef.Value) = '0' then
                exit;
        end;
        lfrfFieldRef := prrfLine.Field(2);
        if ((lintTableNo <> DATABASE::"Sales Line") and
          (lintTableNo <> DATABASE::"Sales Invoice Line") and
          (lintTableNo <> DATABASE::"Sales Cr.Memo Line")) then //<ENRE1.00>
            if not lrecVendor.Get(Format(lfrfFieldRef.Value)) then
                exit;

        //<ENRE1.00>
        if (
          (lintTableNo in [DATABASE::"Sales Line", DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"])
        ) then begin
            if (
              (Format(lfrfFieldRef.Value) = '')
              or (not lrecCustomer.Get(Format(lfrfFieldRef.Value)))
            ) then begin
                exit;
            end;
        end;
        //</ENRE1.00>

        lfrfFieldRef := prrfLine.Field(6);
        if Format(lfrfFieldRef.Value) <> '' then begin
            if not lrecItem.Get(Format(lfrfFieldRef.Value)) then
                exit;
        end else begin
            lfrfFieldRef := prrfLine.Field(6);

            if not lrecItem.Get(Format(lfrfFieldRef.Value)) then
                exit;
        end;

        lrecTempRebate.Reset;
        lrecTempRebate.DeleteAll;

        lrecRebate.Reset;

        if not gblnSalesBasedRebateMode then begin
            //-- If the Periodic Calc routine has been run with filters, we need to use them in this calculation
            lrecRebate.CopyFilters(gRecPurchRebateHeaderFilter);

            lrecRebate.SetFilter("Start Date", '%1|<=%2', 0D, ldteOrderDate);
            lrecRebate.SetFilter("End Date", '%1|>=%2', 0D, ldteOrderDate);

            lrecRebate.SetRange("Apply-To Vendor No.", lrecVendor."No.");
            lrecRebate.SetFilter("Apply-To Order Address Code", '%1|%2', '', lcodShiptoCode);

            lrecRebate.SetFilter("Rebate Type", '<>%1', lrecRebate."Rebate Type"::"Sales-Based");

            if lrecRebate.FindSet then begin
                repeat
                    lrecTempRebate.Init;
                    lrecTempRebate.TransferFields(lrecRebate);
                    if lrecTempRebate.Insert then;
                until lrecRebate.Next = 0;
            end;

            lrecRebate.SetFilter("Apply-To Vendor No.", '%1', '');
            lrecRebate.SetFilter("Apply-To Order Address Code", '%1', '');
            lrecRebate.SetFilter("Apply-To Vendor Group Code", '%1|%2', '', lrecVendor."Rebate Group Code ELA");
            lrecRebate.SetFilter("Start Date", '%1|<=%2', 0D, ldteOrderDate);
            lrecRebate.SetFilter("End Date", '%1|>=%2', 0D, ldteOrderDate);

            if lrecRebate.FindSet then begin
                repeat
                    lrecTempRebate.Init;
                    lrecTempRebate.TransferFields(lrecRebate);
                    if lrecTempRebate.Insert then;
                until lrecRebate.Next = 0;
            end;
        end else begin
            //-- If the Periodic Calc routine has been run with filters, we need to use them in this calculation
            lrecRebate.CopyFilters(gRecPurchRebateHeaderFilter);

            lrecRebate.SetFilter("Start Date", '%1|<=%2', 0D, ldteOrderDate);
            lrecRebate.SetFilter("End Date", '%1|>=%2', 0D, ldteOrderDate);

            lrecRebate.SetRange("Rebate Type", lrecRebate."Rebate Type"::"Sales-Based");

            // grab the Sales-Based Purch Rebates that apply to ALL customers
            // ( no Purchase Rebate Customers are specified )
            if lrecRebate.FindSet then begin
                repeat
                    lrecRebateCust.SetRange("Purchase Rebate Code", lrecRebate.Code);
                    if lrecRebateCust.IsEmpty then begin
                        lrecTempRebate.Init;
                        lrecTempRebate.TransferFields(lrecRebate);
                        if lrecTempRebate.Insert then;
                    end;
                until lrecRebate.Next = 0;
            end;

            // grab the Sales-Based Purch Rebates that apply to THIS customer
            lrecRebateCust.Reset;
            lrecRebateCust.SetRange("Customer No.", lrecCustomer."No.");
            lrecRebateCust.SetFilter("Rebate Start Date", '%1|..%2', 0D, ldteOrderDate);
            lrecRebateCust.SetFilter("Rebate End Date", '%1|>=%2', 0D, ldteOrderDate);
            if lrecRebateCust.FindSet then begin
                repeat
                    lrecRebate.Get(lrecRebateCust."Purchase Rebate Code");
                    lrecTempRebate.Init;
                    lrecTempRebate.TransferFields(lrecRebate);
                    if lrecTempRebate.Insert then;
                until lrecRebateCust.Next = 0;
            end;

            //<ENRE1.00>
            lrecRebate.SetFilter("Rebate Type", '<>%1', lrecRebate."Rebate Type"::"Sales-Based");
            lrecRebate.SetRange("Sales Profit Modifier", true);

            if lrecRebate.FindSet then begin
                repeat
                    lrecILE.SetRange("Entry Type", lrecILE."Entry Type"::Purchase);
                    lrecILE.SetRange("Posting Date", lrecRebate."Start Date", lrecRebate."End Date");
                    lrecILE.SetRange("Item No.", lrecItem."No.");
                    if not lrecILE.IsEmpty then begin
                        lrecTempRebate.Init;
                        lrecTempRebate.TransferFields(lrecRebate);
                        if lrecTempRebate.Insert then;
                    end;
                until lrecRebate.Next = 0;
            end;
            //</ENRE1.00>
        end;

        //---------------------------------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------------------------------
        //---------------DO NOT USE lrecrebate PAST THIS POINT. USE ONLY THE LRECTEMPREBATE TABLE FOR PERFORMANCE!!!------------
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
                lrecRebateLine.SetRange("Purchase Rebate Code", lrecTempRebate.Code);

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

        //---------------------------------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------------------------------
        //-----------------DO NOT USE LRECREBATELINE PAST THIS POINT. USE ONLY THE LRECTEMPREBATELIN TABLE FOR PERFORMANCE!!!--------
        //---------------------------------------------------------------------------------------------------------------------------
        //---------------------------------------------------------------------------------------------------------------------------
        if lrecTempRebate.FindSet then begin
            repeat
                lblnIsApplicableItem := false;
                lblnIsApplicableEntity := false;
                lblnItemCategoryCode := false;
                lblnItemRebateGroup := false;
                lblnspecificitemsdefined := false;
                lblnItemExists := false;
                ldecLineLevelRebateValue := 0;
                lrecTempRebateLine.Reset;
                lrecTempRebateLine.SetRange("Purchase Rebate Code", lrecTempRebate.Code);
                if not lrecTempRebateLine.IsEmpty then begin

                    //-- Dimension
                    lrecTempRebateLine.Reset;
                    lrecTempRebateLine.SetRange("Purchase Rebate Code", lrecTempRebate.Code);
                    lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Dimension);
                    if lrecTempRebateLine.IsEmpty then begin
                        lblnIsApplicableEntity := true;
                    end else begin
                        lrecTempDimSetEntry.Reset;
                        lrecTempDimSetEntry.DeleteAll;

                        lrecTempRebateLine.FindSet;
                        lcodDimValueCodeToUse := '';
                        case lintTableNo of
                            DATABASE::"Purchase Line":
                                begin
                                    lrecPurchLine.Get(lrecPurchHeader."Document Type", lrecPurchHeader."No.", lintLineNo);

                                    DimMgt.GetDimensionSet(lrecTempDimSetEntry, lrecPurchLine."Dimension Set ID");

                                    if lrecTempDimSetEntry.Get(lrecPurchLine."Dimension Set ID", lrecTempRebateLine."Dimension Code") then
                                        lcodDimValueCodeToUse := lrecTempDimSetEntry."Dimension Value Code";
                                end;
                            DATABASE::"Purch. Inv. Line":
                                begin
                                    lrecPurchInvLine.Get(lrecPurchInvHeader."No.", lintLineNo);

                                    DimMgt.GetDimensionSet(lrecTempDimSetEntry, lrecPurchInvLine."Dimension Set ID");

                                    if lrecTempDimSetEntry.Get(lrecPurchInvLine."Dimension Set ID", lrecTempRebateLine."Dimension Code") then
                                        lcodDimValueCodeToUse := lrecTempDimSetEntry."Dimension Value Code";
                                end;
                            DATABASE::"Purch. Cr. Memo Line":
                                begin
                                    lrecPurchCrMemoLine.Get(lrecPurchCrMemoHdr."No.", lintLineNo);

                                    DimMgt.GetDimensionSet(lrecTempDimSetEntry, lrecPurchCrMemoLine."Dimension Set ID");

                                    if lrecTempDimSetEntry.Get(lrecPurchCrMemoLine."Dimension Set ID", lrecTempRebateLine."Dimension Code") then
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
                    end;

                    //Item
                    if lblnIsApplicableEntity then begin
                        lrecTempRebateLine.Reset;
                        lrecTempRebateLine.SetRange("Purchase Rebate Code", lrecTempRebate.Code);
                        lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);
                        if lrecTempRebateLine.IsEmpty then begin
                            lblnIsApplicableItem := true;
                            lblnspecificitemsdefined := true;
                            lblnItemRebateGroup := true;
                            lblnItemCategoryCode := true;
                        end else begin
                            lblnItemRebateGroup := true;
                            lblnItemCategoryCode := true;
                            lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"No.");
                            if not lrecTempRebateLine.IsEmpty then begin
                                lblnspecificitemsdefined := true;
                                lrecTempRebateLine.SetRange(Value, lrecItem."No.");
                                if lrecTempRebateLine.FindFirst then begin
                                    lblnItemExists := true;
                                    lblnIsApplicableItem := lrecTempRebateLine.Include;
                                end else begin
                                    lblnItemExists := false;
                                end;
                            end else begin
                                lblnspecificitemsdefined := false;
                            end;

                            if (not lblnspecificitemsdefined) or
                               ((lblnspecificitemsdefined) and (not lblnItemExists)) then begin
                                lrecTempRebateLine.Reset;

                                lrecTempRebateLine.SetCurrentKey(Source, Type, "Sub-Type");
                                lrecTempRebateLine.SetRange("Purchase Rebate Code", lrecTempRebate.Code);
                                lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);
                                lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"Sub-type");

                                if not lrecTempRebateLine.FindSet then begin
                                    if not lblnspecificitemsdefined then begin
                                        lblnIsApplicableItem := true;
                                    end;
                                end else begin
                                    lRecPurchRebateDetailTEMP.Reset;
                                    lRecPurchRebateDetailTEMP.DeleteAll;

                                    repeat
                                        case lrecTempRebateLine."Sub-Type" of
                                            lrecTempRebateLine."Sub-Type"::"Rebate Group":
                                                begin
                                                    if lrecTempRebateLine.Value = lrecItem."Purch. Rebate Group Code ELA" then begin
                                                        lblnItemRebateGroup := lrecTempRebateLine.Include;
                                                    end else begin
                                                        if lrecTempRebateLine."Sub-Type" <> lRecPurchRebateDetailTEMP."Sub-Type" then begin
                                                            lblnItemRebateGroup := false;
                                                        end;
                                                    end;
                                                end;
                                            lrecTempRebateLine."Sub-Type"::"Category Code":
                                                begin
                                                    if lrecTempRebateLine.Value = lrecItem."Item Category Code" then begin
                                                        lblnItemCategoryCode := lrecTempRebateLine.Include;
                                                    end else begin
                                                        if lrecTempRebateLine."Sub-Type" <> lRecPurchRebateDetailTEMP."Sub-Type" then begin
                                                            lblnItemCategoryCode := false;
                                                        end;
                                                    end;
                                                end;
                                        end;
                                        lRecPurchRebateDetailTEMP := lrecTempRebateLine;
                                    until lrecTempRebateLine.Next = 0;

                                    if (lblnItemRebateGroup) and (lblnItemCategoryCode) then
                                        lblnIsApplicableItem := true;
                                end;
                            end;
                        end;
                    end;

                    if lblnspecificitemsdefined then begin
                        if (lblnItemExists and lblnIsApplicableItem) then begin
                            if lblnIsApplicableItem and lblnIsApplicableEntity then begin
                                CalcRebateFromRebateCode(lrecTempRebate.Code, prrfLine, pblnPeriodicCalc,
                                                            ldecLineLevelRebateValue, lrecItem."No.", precTempRebateEntry);
                            end;
                        end else
                            if (not lblnItemExists) then begin
                                if (lblnIsApplicableEntity
                                  and lblnItemRebateGroup and lblnItemCategoryCode and lblnIsApplicableItem) then begin
                                    CalcRebateFromRebateCode(lrecTempRebate.Code, prrfLine, pblnPeriodicCalc,
                                                                ldecLineLevelRebateValue, lrecItem."No.", precTempRebateEntry);
                                end;
                            end;
                    end else
                        if (lblnIsApplicableEntity and lblnItemRebateGroup and lblnItemCategoryCode) then begin
                            CalcRebateFromRebateCode(lrecTempRebate.Code, prrfLine, pblnPeriodicCalc,
                                                        ldecLineLevelRebateValue, lrecItem."No.", precTempRebateEntry);
                        end;
                end;
            until lrecTempRebate.Next = 0;
        end;
    end;


    procedure CalcRebateFromRebateCode(pcodRebate: Code[20]; prrfLine: RecordRef; pblnPeriodocCalc: Boolean; pdecRebateValue: Decimal; pcodItemNo: Code[20]; var precTempRebateEntry: Record "Rebate Entry ELA")
    var
        lrecRebate: Record "Purchase Rebate Header ELA";
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
        ldecUnitCost: Decimal;
        lrecItem: Record Item;
        lcduUOMMgt: Codeunit "Unit of Measure Management";
        ldecRebateQtyPerUOM: Decimal;
        ldecLineQtyPerUOM: Decimal;
        lrecPurchHeader: Record "Purchase Header";
        lrecPurchInvoiceHdr: Record "Purch. Inv. Header";
        lrecPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        lrecExchRate: Record "Currency Exchange Rate";
        lRecPurchRebateEntry: Record "Rebate Entry ELA";
        lrecPurchLine: Record "Purchase Line";
        lrecPurchInvLine: Record "Purch. Inv. Line";
        lrecPurchCrMemoLine: Record "Purch. Cr. Memo Line";
        ldecLineDiscountAmt: Decimal;
        ldecInvDiscountAmt: Decimal;
        ldecLineAmount: Decimal;
        lfrfFieldRef: FieldRef;
        lrecRebateLine: Record "Purchase Rebate Line ELA";
        lrecTempRebateLine: Record "Purchase Rebate Line ELA" temporary;
        ldecGuaranteedCost: Decimal;
        lcodGuaranteedCostUOM: Code[20];
        ldecSaleUnitCost: Decimal;
        ldecActualUnitCost: Decimal;
        ldecCostDiff: Decimal;
        lrecSalesHeader: Record "Sales Header";
        lrecSalesLine: Record "Sales Line";
        lrecSalesInvoiceHdr: Record "Sales Invoice Header";
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecSalesCrMemoHdr: Record "Sales Cr.Memo Header";
        lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
        lcduCostCalcMgt: Codeunit "Cost Calculation Management";
        lcduCostCalcMgt2: Codeunit "Cst Calculation Management ELA";
        lcodItemNo: Code[20];
        lblnApplyRebate: Boolean;
        lText030: Label '%1 must be %2 in order to apply %3 %4 to %5 %6.';
        lText031: Label '%1 must not be %2 in order to apply %3 %4 to %5 %6.';
        lText032: Label '%1 may not be calculated against Table ID %2.';
        lblnSalesBased: Boolean;
        lText033: Label 'Internal error; %1 should match gblnSalesBasedRebateMode';
        ldatGuaranteedCostDate: Date;
        lrecVendor: Record Vendor;
        lrecrefLine: RecordRef;
        lblnEntriesExist: Boolean;
        lblnCreateZERORebate: Boolean;
        lblnExcludeItemNo: Boolean;
        lblnExcludeItemCategory: Boolean;
        lblnExcludeItemRebateGroup: Boolean;
        ldecQtyBase: Decimal;
        lblnVariableWeight: Boolean;
        lcduVariableWeightManagement: Codeunit "Rebate Sales Functions ELA";
        lrecInvSetup: Record "Inventory Setup";
        lrecRebateUnitOfMeasure: Record "Unit of Measure";
        lrecLineWeightStats: Record "Line Weight Statistics ELA";
        ldecWeight: Decimal;
        lctxtInvalidDocumentLineTable: Label 'Invalid Document Line table.';
        ldecRebateUOMQty: Decimal;
    begin
        if not lrecRebate.Get(pcodRebate) then
            exit;

        if lrecRebate.Blocked then
            exit;

        if pdecRebateValue = 0 then
            pdecRebateValue := lrecRebate."Rebate Value";

        lintTableNo := prrfLine.Number;
        lfrfNo := prrfLine.Field(6);

        lcodItemNo := lfrfNo.Value;

        if not lrecItem.Get(lfrfNo.Value) then
            exit;

        lrecGLSetup.Get;

        //<ENRE1.00>
        if (lintTableNo = 36) then begin
            lblnSalesBased := (lrecRebate."Rebate Type" = lrecRebate."Rebate Type"::"Sales-Based")
                              or (lrecRebate."Sales Profit Modifier");
        end else begin
            lblnSalesBased := (lrecRebate."Rebate Type" = lrecRebate."Rebate Type"::"Sales-Based");
        end;
        //</ENRE1.00>


        if (lblnSalesBased <> gblnSalesBasedRebateMode) and (not lrecRebate."Sales Profit Modifier") then begin
            // Internal error; %1 should match gblnSalesBasedRebateMode
            Error(lText033, Format(lrecRebate."Rebate Type"::"Sales-Based"));
        end;

        case lintTableNo of
            DATABASE::"Sales Line":
                begin
                    lfrfDocType := prrfLine.Field(1);
                    lfrfDocNo := prrfLine.Field(3);
                    lfrfLineNo := prrfLine.Field(4);

                    if not lrecSalesHeader.Get(lfrfDocType.Value, lfrfDocNo.Value) then
                        exit;

                    if not lrecSalesLine.Get(lfrfDocType.Value, lfrfDocNo.Value, lfrfLineNo.Value) then
                        exit;

                    //<ENRE1.00>
                    if not lblnSalesBased then begin
                        Error(lText030, lrecRebate.FieldCaption("Rebate Type"),
                                           Format(lrecRebate."Rebate Type"::"Sales-Based"),
                                           lrecRebate.TableCaption,
                                           lrecRebate.Code,
                                           lrecSalesHeader.TableCaption,
                                           lrecSalesHeader."No.");
                    end;
                    //</ENRE1.00>

                    ldtePostingDate := lrecSalesHeader."Posting Date";
                    ldecCurrencyFactor := lrecSalesHeader."Currency Factor";
                    lcodCurrencyCode := lrecSalesHeader."Currency Code";

                    //<ENRE1.00>
                    if lrecRebate."Calculation Basis" = lrecRebate."Calculation Basis"::"Guaranteed Cost Deal" then begin
                        grecPurchSetup.Get;
                        case grecPurchSetup."Guaranteed Cost Basis ELA" of

                            grecPurchSetup."Guaranteed Cost Basis ELA"::"Last Receipt":
                                begin
                                    case grecPurchSetup."Guaranteed Cost Date Basis ELA" of
                                        grecPurchSetup."Guaranteed Cost Date Basis ELA"::"Order Date":
                                            begin
                                                ldatGuaranteedCostDate := lrecSalesHeader."Order Date";
                                            end;
                                        grecPurchSetup."Guaranteed Cost Date Basis ELA"::"Shipment Date":
                                            begin
                                                ldatGuaranteedCostDate := lrecSalesHeader."Shipment Date";
                                            end;
                                        else begin
                                                grecPurchSetup.FieldError("Guaranteed Cost Date Basis ELA");
                                            end;
                                    end;

                                    ldecSaleUnitCost := CalcLastReceivedUnitCost(lrecRebate."Apply-To Vendor No.",
                                                                                    pcodItemNo, lrecSalesLine."Variant Code",
                                                                                    ldatGuaranteedCostDate, lblnEntriesExist);
                                    //<ENRE1.00>
                                    lblnCreateZERORebate := not lblnEntriesExist;
                                    //</ENRE1.00>
                                end;

                            grecPurchSetup."Guaranteed Cost Basis ELA"::"Adj. Document Cost":
                                begin
                                    ldecSaleUnitCost := lrecSalesLine."Unit Cost (LCY)";
                                end;

                            grecPurchSetup."Guaranteed Cost Basis ELA"::"User-Defined Calculation":
                                begin
                                    lrecrefLine := prrfLine.Duplicate;
                                    OnUserDefinedCostBasisCalculation(lrecrefLine, ldecSaleUnitCost);
                                end;
                        end;
                    end;
                    //<ENRE1.00>
                end;
            DATABASE::"Sales Invoice Line":
                begin
                    lfrfDocNo := prrfLine.Field(3);
                    lfrfLineNo := prrfLine.Field(4);

                    if not lrecSalesInvoiceHdr.Get(lfrfDocNo.Value) then
                        exit;

                    if not lrecSalesInvLine.Get(lfrfDocNo.Value, lfrfLineNo.Value) then
                        exit;

                    //<ENRE1.00>
                    if not lblnSalesBased then begin
                        Error(lText030, lrecRebate.FieldCaption("Rebate Type"),
                                           Format(lrecRebate."Rebate Type"::"Sales-Based"),
                                           lrecRebate.TableCaption,
                                           lrecRebate.Code,
                                           lrecSalesInvoiceHdr.TableCaption,
                                           lrecSalesInvoiceHdr."No.");
                    end;
                    //</ENRE1.00>

                    ldtePostingDate := lrecSalesInvoiceHdr."Posting Date";
                    ldecCurrencyFactor := lrecSalesInvoiceHdr."Currency Factor";
                    lcodCurrencyCode := lrecSalesInvoiceHdr."Currency Code";

                    //<ENRE1.00>
                    if lrecRebate."Calculation Basis" = lrecRebate."Calculation Basis"::"Guaranteed Cost Deal" then begin
                        grecPurchSetup.Get;
                        case grecPurchSetup."Guaranteed Cost Basis ELA" of
                            grecPurchSetup."Guaranteed Cost Basis ELA"::"Last Receipt":
                                begin
                                    case grecPurchSetup."Guaranteed Cost Date Basis ELA" of
                                        grecPurchSetup."Guaranteed Cost Date Basis ELA"::"Order Date":
                                            begin
                                                ldatGuaranteedCostDate := lrecSalesInvoiceHdr."Order Date";
                                            end;
                                        grecPurchSetup."Guaranteed Cost Date Basis ELA"::"Shipment Date":
                                            begin
                                                ldatGuaranteedCostDate := lrecSalesInvoiceHdr."Shipment Date";
                                            end;
                                        else begin
                                                grecPurchSetup.FieldError("Guaranteed Cost Date Basis ELA");
                                            end;
                                    end;

                                    ldecSaleUnitCost := CalcLastReceivedUnitCost(lrecRebate."Apply-To Vendor No.",
                                                                                    pcodItemNo, lrecSalesInvLine."Variant Code",
                                                                                    ldatGuaranteedCostDate, lblnEntriesExist);
                                    //<ENRE1.00>
                                    lblnCreateZERORebate := not lblnEntriesExist;
                                    //</ENRE1.00>
                                end;

                            grecPurchSetup."Guaranteed Cost Basis ELA"::"Adj. Document Cost":
                                begin
                                    lcduCostCalcMgt2.SetExcludeItemCharges(true);
                                    ldecSaleUnitCost := lcduCostCalcMgt.CalcSalesInvLineCostLCY(lrecSalesInvLine) / lrecSalesInvLine.Quantity;
                                    lcduCostCalcMgt2.SetExcludeItemCharges(false);
                                end;

                            grecPurchSetup."Guaranteed Cost Basis ELA"::"User-Defined Calculation":
                                begin
                                    lrecrefLine := prrfLine.Duplicate;
                                    OnUserDefinedCostBasisCalculation(lrecrefLine, ldecSaleUnitCost);
                                end;
                        end;
                    end;
                    //<ENRE1.00>
                end;
            DATABASE::"Sales Cr.Memo Line":
                begin
                    lfrfDocNo := prrfLine.Field(3);
                    lfrfLineNo := prrfLine.Field(4);

                    if not lrecSalesCrMemoHdr.Get(lfrfDocNo.Value) then
                        exit;

                    if not lrecSalesCrMemoLine.Get(lfrfDocNo.Value, lfrfLineNo.Value) then
                        exit;

                    //<ENRE1.00>
                    if not lblnSalesBased then begin
                        Error(lText030, lrecRebate.FieldCaption("Rebate Type"),
                                           Format(lrecRebate."Rebate Type"::"Sales-Based"),
                                           lrecRebate.TableCaption,
                                           lrecRebate.Code,
                                           lrecSalesCrMemoHdr.TableCaption,
                                           lrecSalesCrMemoHdr."No.");
                    end;
                    //</ENRE1.00>

                    ldtePostingDate := lrecSalesCrMemoHdr."Posting Date";
                    ldecCurrencyFactor := lrecSalesCrMemoHdr."Currency Factor";
                    lcodCurrencyCode := lrecSalesCrMemoHdr."Currency Code";

                    //<ENRE1.00>
                    if lrecRebate."Calculation Basis" = lrecRebate."Calculation Basis"::"Guaranteed Cost Deal" then begin
                        grecPurchSetup.Get;
                        case grecPurchSetup."Guaranteed Cost Basis ELA" of
                            grecPurchSetup."Guaranteed Cost Basis ELA"::"Last Receipt":
                                begin
                                    case grecPurchSetup."Guaranteed Cost Date Basis ELA" of
                                        grecPurchSetup."Guaranteed Cost Date Basis ELA"::"Order Date":
                                            begin
                                                ldatGuaranteedCostDate := lrecSalesCrMemoHdr."Order Date ELA";
                                            end;
                                        grecPurchSetup."Guaranteed Cost Date Basis ELA"::"Shipment Date":
                                            begin
                                                ldatGuaranteedCostDate := lrecSalesCrMemoHdr."Shipment Date";
                                            end;
                                        else begin
                                                grecPurchSetup.FieldError("Guaranteed Cost Date Basis ELA");
                                            end;
                                    end;

                                    ldecSaleUnitCost := CalcLastReceivedUnitCost(lrecRebate."Apply-To Vendor No.",
                                                                                    pcodItemNo, lrecSalesCrMemoLine."Variant Code",
                                                                                    ldatGuaranteedCostDate, lblnEntriesExist);
                                    //<ENRE1.00>
                                    lblnCreateZERORebate := not lblnEntriesExist;
                                    //</ENRE1.00>
                                end;

                            grecPurchSetup."Guaranteed Cost Basis ELA"::"Adj. Document Cost":
                                begin
                                    lcduCostCalcMgt2.SetExcludeItemCharges(true);
                                    ldecSaleUnitCost := lcduCostCalcMgt.CalcSalesCrMemoLineCostLCY(lrecSalesCrMemoLine) / lrecSalesCrMemoLine.Quantity;
                                    lcduCostCalcMgt2.SetExcludeItemCharges(false);
                                end;

                            grecPurchSetup."Guaranteed Cost Basis ELA"::"User-Defined Calculation":
                                begin
                                    lrecrefLine := prrfLine.Duplicate;
                                    OnUserDefinedCostBasisCalculation(lrecrefLine, ldecSaleUnitCost);
                                end;
                        end;
                    end;
                    //<ENRE1.00>
                end;
            DATABASE::"Purchase Line":
                begin
                    lfrfDocType := prrfLine.Field(1);
                    lfrfDocNo := prrfLine.Field(3);
                    lfrfLineNo := prrfLine.Field(4);

                    if not lrecPurchHeader.Get(lfrfDocType.Value, lfrfDocNo.Value) then
                        exit;

                    if not lrecPurchLine.Get(lfrfDocType.Value, lfrfDocNo.Value, lfrfLineNo.Value) then
                        exit;

                    //<ENRE1.00>
                    if lblnSalesBased then begin
                        Error(lText031, lrecRebate.FieldCaption("Rebate Type"),
                                           Format(lrecRebate."Rebate Type"),
                                           lrecRebate.TableCaption,
                                           lrecRebate.Code,
                                           lrecPurchHeader.TableCaption,
                                           lrecPurchHeader."No.");
                    end;
                    //</ENRE1.00>

                    ldtePostingDate := lrecPurchHeader."Posting Date";
                    ldecCurrencyFactor := lrecPurchHeader."Currency Factor";
                    lcodCurrencyCode := lrecPurchHeader."Currency Code";
                end;
            DATABASE::"Purch. Inv. Line":
                begin
                    lfrfDocNo := prrfLine.Field(3);
                    lfrfLineNo := prrfLine.Field(4);
                    if not lrecPurchInvoiceHdr.Get(lfrfDocNo.Value) then
                        exit;
                    if not lrecPurchInvLine.Get(lfrfDocNo.Value, lfrfLineNo.Value) then
                        exit;
                    //<ENRE1.00>
                    if (
                      (lblnSalesBased)
                    ) then begin
                        // %1 must not be %2 in order to apply %3 %4 to %5 %6.
                        Error(lText031, lrecRebate.FieldCaption("Rebate Type"),
                                           Format(lrecRebate."Rebate Type"),
                                           lrecRebate.TableCaption,
                                           lrecRebate.Code,
                                           lrecPurchInvoiceHdr.TableCaption,
                                           lrecPurchInvoiceHdr."No.");
                    end;
                    //</ENRE1.00>

                    ldtePostingDate := lrecPurchInvoiceHdr."Posting Date";
                    ldecCurrencyFactor := lrecPurchInvoiceHdr."Currency Factor";
                    lcodCurrencyCode := lrecPurchInvoiceHdr."Currency Code";
                end;
            DATABASE::"Purch. Cr. Memo Line":
                begin
                    lfrfDocNo := prrfLine.Field(3);
                    lfrfLineNo := prrfLine.Field(4);

                    if not lrecPurchCrMemoHdr.Get(lfrfDocNo.Value) then
                        exit;

                    if not lrecPurchCrMemoLine.Get(lfrfDocNo.Value, lfrfLineNo.Value) then
                        exit;

                    //<ENRE1.00>
                    if lblnSalesBased then begin
                        Error(lText031, lrecRebate.FieldCaption("Rebate Type"),
                                           Format(lrecRebate."Rebate Type"),
                                           lrecRebate.TableCaption,
                                           lrecRebate.Code,
                                           lrecPurchCrMemoHdr.TableCaption,
                                           lrecPurchCrMemoHdr."No.");
                    end;
                    //</ENRE1.00>

                    ldtePostingDate := lrecPurchCrMemoHdr."Posting Date";
                    ldecCurrencyFactor := lrecPurchCrMemoHdr."Currency Factor";
                    lcodCurrencyCode := lrecPurchCrMemoHdr."Currency Code";
                end else begin
                            Error(lText032, lrecRebate.TableCaption, Format(lintTableNo));
                        end;
        end;

        Clear(ldecRebateAmtLCY);
        Clear(ldecRebateAmtRBT);
        Clear(ldecRebateAmtDOC);


        case lrecRebate."Calculation Basis" of
            lrecRebate."Calculation Basis"::"Pct. Purch.($)":
                begin
                    lfrfQuantity := prrfLine.Field(15);
                    lfrfUOM := prrfLine.Field(13);
                    grecPurchSetup.Get;
                    lfrfUnitPrice := prrfLine.Field(22);
                    Evaluate(ldecUnitCost, Format(lfrfUnitPrice.Value));
                    lfrfLineDiscountAmt := prrfLine.Field(28);
                    lfrfInvDiscountAmt := prrfLine.Field(69);
                    Evaluate(ldecLineQuantity, Format(lfrfQuantity.Value));
                    Evaluate(ldecLineDiscountAmt, Format(lfrfLineDiscountAmt.Value));
                    Evaluate(ldecInvDiscountAmt, Format(lfrfInvDiscountAmt.Value));
                    ldecLineAmount := (ldecLineQuantity * ldecUnitCost) - (ldecLineDiscountAmt + ldecInvDiscountAmt);

                    if grecPurchSetup."Calc. Rbt After Discounts ELA" then begin
                        ldecRebateAmtDOC := (((ldecLineQuantity * ldecUnitCost) - (ldecLineDiscountAmt + ldecInvDiscountAmt)) *
                                             (pdecRebateValue / 100));
                    end else begin
                        ldecRebateAmtDOC := ldecLineQuantity * ldecUnitCost * (pdecRebateValue / 100);
                    end;

                    ldecLineAmount := lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lcodCurrencyCode,
                                                                       lrecRebate."Currency Code", ldecLineAmount);
                    if Abs(ldecLineAmount) < lrecRebate."Minimum Amount" then
                        exit;

                    //<ENRE1.00>
                    if (lrecRebate."Maximum Amount" <> 0) and (Abs(ldecLineAmount) > lrecRebate."Maximum Amount") then
                        exit;
                    //</ENRE1.00>

                    ldecRebateAmtRBT := ldecRebateAmtDOC;

                    if lcodCurrencyCode = '' then begin
                        ldecRebateAmtLCY := ldecRebateAmtDOC;
                    end else begin
                        ldecRebateAmtLCY := lrecExchRate.ExchangeAmtFCYToLCY(ldtePostingDate,
                                               lcodCurrencyCode, ldecRebateAmtDOC, ldecCurrencyFactor);
                    end;

                    CreateRebateEntry(lRecPurchRebateEntry."Functional Area"::Purchase, prrfLine,
                                         pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                         pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);
                end;
            lrecRebate."Calculation Basis"::"($)/Unit":
                begin
                    lfrfNo := prrfLine.Field(6);
                    if not lrecItem.Get(lfrfNo.Value) then
                        exit;
                    ldecRebateQtyPerUOM := 1;

                    if lrecRebate."Unit of Measure Code" <> lrecItem."Base Unit of Measure" then
                        ldecRebateQtyPerUOM := lcduUOMMgt.GetQtyPerUnitOfMeasure(lrecItem, lrecRebate."Unit of Measure Code");

                    lfrfQuantity := prrfLine.Field(15);
                    lfrfUOM := prrfLine.Field(13);
                    lfrfUnitPrice := prrfLine.Field(22);
                    lfrfLineDiscountAmt := prrfLine.Field(28);
                    lfrfInvDiscountAmt := prrfLine.Field(69);
                    lfrfFieldRef := prrfLine.Field(5404);
                    Evaluate(ldecLineQtyPerUOM, Format(lfrfFieldRef.Value));
                    Evaluate(ldecLineQuantity, Format(lfrfQuantity.Value));
                    Evaluate(ldecUnitCost, Format(lfrfUnitPrice.Value));
                    Evaluate(ldecLineDiscountAmt, Format(lfrfLineDiscountAmt.Value));
                    Evaluate(ldecInvDiscountAmt, Format(lfrfInvDiscountAmt.Value));
                    ldecLineAmount := (ldecLineQuantity * ldecUnitCost) - (ldecLineDiscountAmt + ldecInvDiscountAmt);

                    //<ENRE1.00>
                    ldecQtyBase := lcduUOMMgt.CalcBaseQty(ldecLineQuantity, ldecLineQtyPerUOM);

                    if Abs(ldecQtyBase) < lrecRebate."Minimum Quantity (Base)" then
                        exit;

                    if (lrecRebate."Maximum Quantity (Base)" <> 0) and
                      (Abs(ldecQtyBase) > lrecRebate."Maximum Quantity (Base)") then
                        exit;

                    lblnVariableWeight := lcduVariableWeightManagement.IsCatchWeightItem(pcodItemNo, false);

                    if (
                      (lblnVariableWeight)
                    ) then begin
                        lrecInvSetup.Get;
                        lrecInvSetup.TestField("Standard Weight UOM ELA");
                        lrecRebate.TestField("Unit of Measure Code");
                        lrecRebateUnitOfMeasure.Get(lrecRebate."Unit of Measure Code");
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
                                    ldecWeight := lrecSalesInvLine."Line Net Weight ELA";
                                end;
                            DATABASE::"Sales Cr.Memo Line":
                                begin
                                    ldecWeight := lrecSalesCrMemoLine."Line Net Weight ELA";
                                end;

                            DATABASE::"Purchase Line":
                                begin
                                    Clear(lrecLineWeightStats);
                                    lcduVariableWeightManagement.CalcLineWeightStats(prrfLine, lrecLineWeightStats, 0);
                                    ldecWeight := lrecLineWeightStats."Total Net Weight";
                                end;

                            DATABASE::"Purch. Inv. Line":
                                begin
                                    ldecWeight := lrecPurchInvLine."Line Net Weight ELA";
                                end;
                            DATABASE::"Purch. Cr. Memo Line":
                                begin
                                    ldecWeight := lrecPurchCrMemoLine."Line Net Weight ELA";
                                end;
                            else begin
                                    Error(lctxtInvalidDocumentLineTable);
                                end;
                        end;

                        if (
                          (lrecRebate."Unit of Measure Code" = lrecInvSetup."Standard Weight UOM ELA")
                        ) then begin
                            ldecRebateUOMQty := ldecWeight;
                        end else begin
                            lrecRebateUnitOfMeasure.TestField("Std. Qty. Per UOM ELA");
                            ldecRebateUOMQty := ldecWeight / lrecRebateUnitOfMeasure."Std. Qty. Per UOM ELA";
                        end;

                    end else begin
                        if (
                          (lrecRebate."Unit of Measure Code" = Format(lfrfUOM))
                        ) then begin
                            ldecRebateUOMQty := ldecLineQuantity;
                        end else begin
                            ldecRebateUOMQty := ldecLineQuantity * ldecLineQtyPerUOM / ldecRebateQtyPerUOM;
                        end;
                    end;
                    //</ENRE1.00>

                    if lrecRebate."Currency Code" = lcodCurrencyCode then begin
                        if Abs(ldecLineAmount) < lrecRebate."Minimum Amount" then
                            exit;

                        if (lrecRebate."Maximum Amount" <> 0) and (Abs(ldecLineAmount) > lrecRebate."Maximum Amount") then
                            exit;

                        ldecRebateAmtDOC := ldecRebateUOMQty * pdecRebateValue; //<ENRE1.00>
                        ldecRebateAmtRBT := ldecRebateAmtDOC;
                        if lcodCurrencyCode = '' then begin
                            ldecRebateAmtLCY := ldecRebateAmtDOC;
                        end else begin
                            if lrecRebate."Currency Code" <> lrecGLSetup."LCY Code" then begin
                                ldecRebateAmtLCY := ldecRebateUOMQty * //<ENRE1.00>
                                  lrecExchRate.ExchangeAmtFCYToLCY(ldtePostingDate,
                                  lrecRebate."Currency Code", pdecRebateValue, ldecCurrencyFactor);
                            end else begin
                                ldecRebateAmtLCY := ldecRebateAmtDOC;
                            end;
                        end;
                        CreateRebateEntry(lRecPurchRebateEntry."Functional Area"::Purchase, prrfLine,
                                             pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                             pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);
                    end else
                        if (lrecRebate."Currency Code" <> lcodCurrencyCode) and
                 ((lrecRebate."Currency Code" <> '') and (lcodCurrencyCode <> '')) then begin
                            if Abs(ldecLineAmount) < lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lrecRebate."Currency Code",
                                                                                      lcodCurrencyCode, lrecRebate."Minimum Amount") then
                                exit;

                            if (lrecRebate."Maximum Amount" <> 0) and
                               (Abs(ldecLineAmount) > lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lrecRebate."Currency Code",
                                                                                      lcodCurrencyCode, lrecRebate."Maximum Amount")) then
                                exit;

                            ldecRebateAmtDOC := ldecRebateUOMQty * //<ENRE1.00>
                                                lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate,
                                                lrecRebate."Currency Code",
                                                lcodCurrencyCode, pdecRebateValue);
                            ldecRebateAmtLCY := ldecRebateUOMQty * //<ENRE1.00>
                                                lrecExchRate.ExchangeAmtFCYToLCY(ldtePostingDate,
                                                lcodCurrencyCode, ldecRebateAmtDOC, ldecCurrencyFactor);
                            ldecRebateAmtRBT := ldecRebateUOMQty * pdecRebateValue; //<ENRE1.00>
                            CreateRebateEntry(lRecPurchRebateEntry."Functional Area"::Purchase, prrfLine,
                                                 pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                                 pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);
                        end else
                            if ((lrecRebate."Currency Code" = '') and (lcodCurrencyCode <> '')) then begin
                                if Abs(ldecLineAmount)
                                  < lrecExchRate.ExchangeAmtLCYToFCYOnlyFactor(lrecRebate."Minimum Amount", ldecCurrencyFactor) then
                                    exit;

                                if (lrecRebate."Maximum Amount" <> 0) and
                                   (Abs(ldecLineAmount) >
                                        lrecExchRate.ExchangeAmtLCYToFCYOnlyFactor(lrecRebate."Maximum Amount", ldecCurrencyFactor)) then
                                    exit;

                                ldecRebateAmtLCY := ldecRebateUOMQty * pdecRebateValue; //<ENRE1.00>
                                ldecRebateAmtRBT := ldecRebateAmtLCY;
                                ldecRebateAmtDOC := lrecExchRate.ExchangeAmtLCYToFCYOnlyFactor(ldecRebateAmtLCY, ldecCurrencyFactor);

                                CreateRebateEntry(lRecPurchRebateEntry."Functional Area"::Purchase, prrfLine,
                                                     pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                                     pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);
                            end else
                                if (lrecRebate."Currency Code" <> '') and (lcodCurrencyCode = '') then begin
                                    if Abs(ldecLineAmount) < lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lrecRebate."Currency Code",
                                                                                              lcodCurrencyCode, lrecRebate."Minimum Amount") then
                                        exit;

                                    if (lrecRebate."Maximum Amount" <> 0) and
                                       (Abs(ldecLineAmount) > lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate, lrecRebate."Currency Code",
                                                                                              lcodCurrencyCode, lrecRebate."Maximum Amount")) then
                                        exit;

                                    ldecRebateAmtLCY := ldecRebateUOMQty * //<ENRE1.00>
                                                     lrecExchRate.ExchangeAmtFCYToFCY(ldtePostingDate,
                                                     lrecRebate."Currency Code",
                                                     lcodCurrencyCode, pdecRebateValue);

                                    ldecRebateAmtDOC := ldecRebateAmtLCY;
                                    ldecRebateAmtRBT := ldecRebateUOMQty * pdecRebateValue; //<ENRE1.00>

                                    CreateRebateEntry(lRecPurchRebateEntry."Functional Area"::Purchase, prrfLine,
                                                         pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                                         pblnPeriodocCalc, false, pdecRebateValue, pcodItemNo, precTempRebateEntry, lcodCurrencyCode);
                                end;
                end;
            //<ENRE1.00>
            lrecRebate."Calculation Basis"::"Guaranteed Cost Deal":
                begin
                    lrecTempRebateLine.Reset;
                    lrecTempRebateLine.DeleteAll;

                    lrecRebateLine.Reset;
                    lrecRebateLine.SetRange("Purchase Rebate Code", lrecRebate.Code);

                    //-- Load up temp table for later to avoid going back to server multiple times for same records
                    if not lrecRebateLine.IsEmpty then begin
                        lrecRebateLine.FindSet;

                        repeat
                            lrecTempRebateLine.Init;
                            lrecTempRebateLine.TransferFields(lrecRebateLine);
                            lrecTempRebateLine.Insert;
                        until lrecRebateLine.Next = 0;
                    end;

                    lrecRebateLine.Reset;
                    lrecRebateLine.SetRange("Purchase Rebate Code", lrecRebate.Code);
                    lrecRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);
                    lrecRebateLine.SetRange(Include, true);

                    if lrecRebateLine.FindSet then
                        repeat
                            Clear(ldecGuaranteedCost);
                            Clear(lcodGuaranteedCostUOM);

                            case lrecTempRebateLine.Type of
                                lrecRebateLine.Type::"No.":
                                    begin
                                        lblnApplyRebate := lcodItemNo = lrecRebateLine.Value;
                                        lrecRebateLine.TestField("Guaranteed Cost UOM Code");
                                        ldecGuaranteedCost := lrecRebateLine."Guaranteed Unit Cost (LCY)";
                                        lcodGuaranteedCostUOM := lrecRebateLine."Guaranteed Cost UOM Code";
                                    end;
                                lrecRebateLine.Type::"Sub-type":
                                    begin
                                        lblnApplyRebate := true;
                                        if lrecItem.Get(lcodItemNo) then begin
                                            if (lrecRebateLine."Sub-Type" = lrecRebateLine."Sub-Type"::"Rebate Group") then begin
                                                if lrecItem."Purch. Rebate Group Code ELA" = lrecRebateLine.Value then begin
                                                    lrecTempRebateLine.Reset;
                                                    lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);
                                                    lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"No.");
                                                    lrecTempRebateLine.SetRange(Value, lrecItem."No.");
                                                    lrecTempRebateLine.SetRange(Include, false);
                                                    lblnExcludeItemNo := not lrecTempRebateLine.IsEmpty;

                                                    lrecTempRebateLine.Reset;
                                                    lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);
                                                    lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"Sub-type");
                                                    lrecTempRebateLine.SetRange("Sub-Type", lrecTempRebateLine."Sub-Type"::"Category Code");
                                                    lrecTempRebateLine.SetRange(Value, lrecItem."Item Category Code");
                                                    lrecTempRebateLine.SetRange(Include, false);
                                                    lblnExcludeItemCategory := not lrecTempRebateLine.IsEmpty;


                                                    lblnApplyRebate := (not lblnExcludeItemNo) and (not lblnExcludeItemCategory);
                                                end;
                                            end else
                                                if (lrecRebateLine."Sub-Type" = lrecRebateLine."Sub-Type"::"Category Code") then begin
                                                    if lrecItem."Purch. Rebate Group Code ELA" = lrecRebateLine.Value then begin
                                                        lrecTempRebateLine.Reset;
                                                        lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);
                                                        lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"No.");
                                                        lrecTempRebateLine.SetRange(Value, lrecItem."No.");
                                                        lrecTempRebateLine.SetRange(Include, false);
                                                        lblnExcludeItemNo := not lrecTempRebateLine.IsEmpty;

                                                        lrecTempRebateLine.Reset;
                                                        lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);
                                                        lrecTempRebateLine.SetRange(Type, lrecTempRebateLine.Type::"Sub-type");
                                                        lrecTempRebateLine.SetRange("Sub-Type", lrecTempRebateLine."Sub-Type"::"Rebate Group");
                                                        lrecTempRebateLine.SetRange(Value, lrecItem."Purch. Rebate Group Code ELA");
                                                        lrecTempRebateLine.SetRange(Include, false);
                                                        lblnExcludeItemRebateGroup := not lrecTempRebateLine.IsEmpty;


                                                        lblnApplyRebate := (not lblnExcludeItemNo) and (not lblnExcludeItemRebateGroup);
                                                    end;
                                                end;

                                            if lblnApplyRebate then begin
                                                lrecRebateLine.TestField("Guaranteed Cost UOM Code");
                                                ldecGuaranteedCost := lrecTempRebateLine."Guaranteed Unit Cost (LCY)";
                                                lcodGuaranteedCostUOM := lrecTempRebateLine."Guaranteed Cost UOM Code";
                                            end;
                                        end;
                                    end;
                            end;

                            if lblnApplyRebate then begin
                                lrecRebate.TestField("Currency Code", '');
                                ldecRebateQtyPerUOM := 1;

                                case lintTableNo of
                                    DATABASE::"Sales Line":
                                        begin
                                            lrecSalesHeader.TestField("Currency Code", '');
                                        end;
                                    DATABASE::"Purchase Line":
                                        begin
                                            lrecPurchHeader.TestField("Currency Code", '');
                                        end;
                                    DATABASE::"Sales Invoice Line":
                                        begin
                                            lrecSalesInvoiceHdr.TestField("Currency Code", '');
                                        end;
                                    DATABASE::"Sales Cr.Memo Line":
                                        begin
                                            lrecSalesCrMemoHdr.TestField("Currency Code", '');
                                        end;
                                    DATABASE::"Purch. Inv. Line":
                                        begin
                                            lrecPurchInvoiceHdr.TestField("Currency Code", '');
                                        end;
                                    DATABASE::"Purch. Cr. Memo Line":
                                        begin
                                            lrecPurchCrMemoHdr.TestField("Currency Code", '');
                                        end;
                                end;

                                if lcodGuaranteedCostUOM <> lrecItem."Base Unit of Measure" then
                                    ldecRebateQtyPerUOM := lcduUOMMgt.GetQtyPerUnitOfMeasure(lrecItem, lcodGuaranteedCostUOM);

                                lfrfLineDiscountAmt := prrfLine.Field(28);
                                lfrfInvDiscountAmt := prrfLine.Field(69);
                                lfrfQuantity := prrfLine.Field(15);
                                lfrfUOM := prrfLine.Field(13);
                                lfrfUnitPrice := prrfLine.Field(22);
                                lfrfFieldRef := prrfLine.Field(5404);
                                Evaluate(ldecLineQtyPerUOM, Format(lfrfFieldRef.Value));
                                Evaluate(ldecLineQuantity, Format(lfrfQuantity.Value));
                                Evaluate(ldecUnitCost, Format(lfrfUnitPrice.Value));
                                ldecGuaranteedCost := (ldecGuaranteedCost / ldecRebateQtyPerUOM) * ldecLineQtyPerUOM;
                                ldecLineAmount := (ldecLineQuantity * ldecUnitCost) - (ldecLineDiscountAmt + ldecInvDiscountAmt);

                                if lintTableNo in [DATABASE::"Sales Line", DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                                    ldecActualUnitCost := ldecSaleUnitCost;
                                end else begin
                                    ldecActualUnitCost := ldecUnitCost * ldecLineQtyPerUOM;
                                end;

                                ldecCostDiff := (ldecActualUnitCost - ldecGuaranteedCost);

                                if ldecLineQtyPerUOM <> ldecRebateQtyPerUOM then begin
                                    if Abs(ldecLineQuantity) < ldecRebateQtyPerUOM * lrecRebate."Minimum Quantity (Base)" then
                                        exit;

                                    if (lrecRebate."Maximum Quantity (Base)" <> 0) and
                                      (Abs(ldecLineQuantity) > ldecRebateQtyPerUOM * lrecRebate."Maximum Quantity (Base)") then
                                        exit;
                                end else begin
                                    if Abs(ldecLineQuantity) < lrecRebate."Minimum Quantity (Base)" then
                                        exit;

                                    if (lrecRebate."Maximum Quantity (Base)" <> 0) and
                                      (Abs(ldecLineQuantity) > lrecRebate."Maximum Quantity (Base)") then
                                        exit;
                                end;

                                if Abs(ldecLineAmount) < lrecRebate."Minimum Amount" then
                                    exit;

                                if (lrecRebate."Maximum Amount" <> 0) and (Abs(ldecLineAmount) > lrecRebate."Maximum Amount") then
                                    exit;

                                if (ldecCostDiff <> 0) and (ldecLineQuantity > 0) then begin
                                    // special case - create ZERO dollar rebate
                                    if lblnCreateZERORebate then begin
                                        ldecCostDiff := 0;
                                    end;

                                    ldecRebateAmtDOC := ldecLineQuantity * ldecCostDiff;
                                    ldecRebateAmtRBT := ldecRebateAmtDOC;
                                    ldecRebateAmtLCY := ldecRebateAmtDOC;
                                    lcodCurrencyCode := '';

                                    CreateRebateEntry(lRecPurchRebateEntry."Functional Area"::Purchase, prrfLine,
                                                         pcodRebate, ldecRebateAmtLCY, ldecRebateAmtRBT, ldecRebateAmtDOC,
                                                         pblnPeriodocCalc, false, ldecCostDiff,
                                                         pcodItemNo, precTempRebateEntry, lcodCurrencyCode);
                                end;
                            end;
                        until lrecRebateLine.Next = 0;
                end;
        //</ENRE1.00>
        end;
    end;



    procedure CreateRebateEntry(poptFunctionalArea: Option Sales,Purchase; prrfLine: RecordRef; pcodRebateCode: Code[20]; pdecAmountLCY: Decimal; pdecAmountRBT: Decimal; pdecAmountDOC: Decimal; pbolIsPeriodic: Boolean; pbolAdjustment: Boolean; pdecRebateValue: Decimal; pcodItemNo: Code[20]; var precTempRebateEntry: Record "Rebate Entry ELA" temporary; pcodCurrencyCode: Code[10])
    var
        lrecPurchHeader: Record "Sales Header";
        lrecPurchInv: Record "Purch. Inv. Header";
        lrecPurchCrMemo: Record "Purch. Cr. Memo Hdr.";
        lRecPurchRebateEntry: Record "Rebate Entry ELA";
        lrecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
        lRecPurchRebateEntry2: Record "Rebate Entry ELA";
        lrecPostedRebateEntry2: Record "Rebate Ledger Entry ELA";
        lintEntryNo: Integer;
        lintTableNo: Integer;
        lfrfRbtDocType: FieldRef;
        lfrfRbtDocNo: FieldRef;
        lfrfRbtDocLineNo: FieldRef;
        lfrfPayToVendor: FieldRef;
        lfrfPayToName: FieldRef;
        lfrfBuyFromVendor: FieldRef;
        lfrfPostingDate: FieldRef;
        lfrfFieldRef: FieldRef;
        lfrfDocCurrencyCode: FieldRef;
        lRecPurchRebateHeader: Record "Purchase Rebate Header ELA";
        lrecPurchRebateLedger: Record "Rebate Ledger Entry ELA";
        lrecVendor: Record Vendor;
        lrecItem: Record Item;
        lrecCurrExchange: Record "Currency Exchange Rate";
        lrecSalesProfitMod: Record "Sales Profit Modifier ELA";
        lrecPostedSalesProfitMod: Record "Post. Sales Prof. Modifier ELA";
    begin
        lintTableNo := prrfLine.Number;

        if not pbolIsPeriodic then begin
            case lintTableNo of
                39:
                    begin
                        lRecPurchRebateEntry2.Reset;
                        lRecPurchRebateEntry2.LockTable;

                        if lRecPurchRebateEntry2.FindLast then begin
                            lintEntryNo := lRecPurchRebateEntry2."Entry No." + 1;
                        end else begin
                            lintEntryNo := 1;
                        end;

                        lRecPurchRebateEntry.Init;
                        lRecPurchRebateEntry."Entry No." := lintEntryNo;
                        lRecPurchRebateEntry."Functional Area" := poptFunctionalArea;
                        lfrfRbtDocType := prrfLine.Field(1);
                        lRecPurchRebateEntry."Source Type" := lfrfRbtDocType.Value;
                        lfrfRbtDocNo := prrfLine.Field(3);
                        lRecPurchRebateEntry.Validate("Source No.", Format(lfrfRbtDocNo.Value));
                        lfrfRbtDocLineNo := prrfLine.Field(4);
                        lRecPurchRebateEntry."Source Line No." := lfrfRbtDocLineNo.Value;
                        lRecPurchRebateEntry."Currency Code (DOC)" := pcodCurrencyCode;
                        lRecPurchRebateHeader.Get(pcodRebateCode);
                        lRecPurchRebateEntry."Currency Code (RBT)" := lRecPurchRebateHeader."Currency Code";
                        lRecPurchRebateEntry.Validate("Rebate Code", pcodRebateCode);
                        lRecPurchRebateEntry.Validate("Item No.", pcodItemNo);
                        lRecPurchRebateEntry."Post-to Vendor No." := GetAccrualVendor(pcodRebateCode,
                                                                    lRecPurchRebateEntry."Buy-from Vendor No.",
                                                                    lRecPurchRebateEntry."Pay-to Vendor No.");
                        if (Format(lfrfRbtDocType.Value) = '3') or (Format(lfrfRbtDocType.Value) = '5') then begin
                            lRecPurchRebateEntry.Validate("Amount (LCY)", -pdecAmountLCY);
                            lRecPurchRebateEntry.Validate("Amount (RBT)", -pdecAmountRBT);
                            lRecPurchRebateEntry.Validate("Amount (DOC)", -pdecAmountDOC);
                        end else begin
                            lRecPurchRebateEntry.Validate("Amount (LCY)", pdecAmountLCY);
                            lRecPurchRebateEntry.Validate("Amount (RBT)", pdecAmountRBT);
                            lRecPurchRebateEntry.Validate("Amount (DOC)", pdecAmountDOC);
                        end;
                        if (lRecPurchRebateEntry."Amount (LCY)" <> 0) or
                           (lRecPurchRebateEntry."Amount (RBT)" <> 0) or
                           (lRecPurchRebateEntry."Amount (DOC)" <> 0) then
                            lRecPurchRebateEntry.Insert(true);
                    end;
                123, 125:
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
                        case lintTableNo of
                            123:
                                begin
                                    lrecPostedRebateEntry."Source Type" := lrecPostedRebateEntry."Source Type"::"Posted Invoice";
                                end;
                            125:
                                begin
                                    lrecPostedRebateEntry."Source Type" := lrecPostedRebateEntry."Source Type"::"Posted Cr. Memo";
                                end;
                        end;
                        lfrfRbtDocNo := prrfLine.Field(3);
                        lrecPostedRebateEntry."Source No." := lfrfRbtDocNo.Value;

                        lfrfRbtDocLineNo := prrfLine.Field(4);
                        lrecPostedRebateEntry."Source Line No." := lfrfRbtDocLineNo.Value;
                        lrecPostedRebateEntry."Currency Code (DOC)" := pcodCurrencyCode;
                        lRecPurchRebateHeader.Get(pcodRebateCode);
                        lrecPostedRebateEntry."Currency Code (RBT)" := lRecPurchRebateHeader."Currency Code";
                        lrecPostedRebateEntry.Validate("Rebate Code", pcodRebateCode);
                        lfrfPayToVendor := prrfLine.Field(68);
                        lrecPostedRebateEntry."Pay-to Vendor No." := lfrfPayToVendor.Value;
                        lfrfBuyFromVendor := prrfLine.Field(2);
                        lrecPostedRebateEntry."Buy-from Vendor No." := lfrfBuyFromVendor.Value;
                        case lrecPostedRebateEntry."Functional Area" of
                            lrecPostedRebateEntry."Functional Area"::Purchase:
                                begin
                                    case lrecPostedRebateEntry."Source Type" of
                                        lrecPostedRebateEntry."Source Type"::"Posted Invoice":
                                            begin
                                                if lrecPurchInv.Get(lrecPostedRebateEntry."Source No.") then
                                                    lrecPostedRebateEntry."Order Address Code" := lrecPurchInv."Order Address Code";
                                            end;
                                        lrecPostedRebateEntry."Source Type"::"Posted Cr. Memo":
                                            begin
                                                if lrecPurchCrMemo.Get(lrecPostedRebateEntry."Source No.") then
                                                    lrecPostedRebateEntry."Order Address Code" := lrecPurchCrMemo."Order Address Code";
                                            end;
                                    end;
                                end;
                        end;
                        lrecPostedRebateEntry.Validate("Item No.", pcodItemNo);
                        lfrfPostingDate := prrfLine.Field(131);
                        lrecPostedRebateEntry."Posting Date" := lfrfPostingDate.Value;
                        lrecPostedRebateEntry."Post-to Vendor No." := GetAccrualVendor(pcodRebateCode,
                                                                          lrecPostedRebateEntry."Buy-from Vendor No.",
                                                                          lrecPostedRebateEntry."Pay-to Vendor No.");
                        case lintTableNo of
                            123:
                                begin
                                    lrecPostedRebateEntry."Source Type" := lrecPostedRebateEntry."Source Type"::"Posted Invoice";
                                    lrecPostedRebateEntry.Validate("Amount (LCY)", pdecAmountLCY);
                                    lrecPostedRebateEntry.Validate("Amount (RBT)", pdecAmountRBT);
                                    lrecPostedRebateEntry.Validate("Amount (DOC)", pdecAmountDOC);
                                end;
                            125:
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
                    end;
                //<ENRE1.00>
                DATABASE::"Sales Line":
                    begin
                        //if  sales based

                        lRecPurchRebateHeader.Get(pcodRebateCode);
                        if lRecPurchRebateHeader."Rebate Type" = lRecPurchRebateHeader."Rebate Type"::"Sales-Based" then begin
                            lintEntryNo := 1;
                            if lRecPurchRebateEntry2.FindLast then
                                lintEntryNo := lRecPurchRebateEntry2."Entry No." + 1;
                            lRecPurchRebateEntry.Init;
                            lRecPurchRebateEntry."Entry No." := lintEntryNo;
                            lRecPurchRebateEntry."Functional Area" := lRecPurchRebateEntry."Functional Area"::Purchase;
                            lrecVendor.Get(lRecPurchRebateHeader."Apply-To Vendor No.");
                            lrecItem.Get(pcodItemNo);
                            lfrfFieldRef := prrfLine.Field(1);
                            lRecPurchRebateEntry."Source Type" := lfrfFieldRef.Value;
                            lfrfFieldRef := prrfLine.Field(3);
                            lRecPurchRebateEntry."Source No." := lfrfFieldRef.Value;
                            lfrfFieldRef := prrfLine.Field(4);
                            lRecPurchRebateEntry."Source Line No." := lfrfFieldRef.Value;
                            lRecPurchRebateEntry."Posting Date" := lRecPurchRebateHeader."Start Date";
                            lRecPurchRebateEntry.Validate("Rebate Code", lRecPurchRebateHeader.Code);
                            lRecPurchRebateEntry.Validate("Item No.", lrecItem."No.");
                            lfrfRbtDocType := prrfLine.Field(1);
                            if (Format(lfrfRbtDocType.Value) = '3') or (Format(lfrfRbtDocType.Value) = '5') then begin
                                lRecPurchRebateEntry.Validate("Amount (LCY)", -pdecAmountLCY);
                                lRecPurchRebateEntry.Validate("Amount (RBT)", -pdecAmountRBT);
                                lRecPurchRebateEntry.Validate("Amount (DOC)", -pdecAmountDOC);
                            end else begin
                                lRecPurchRebateEntry.Validate("Amount (LCY)", pdecAmountLCY);
                                lRecPurchRebateEntry.Validate("Amount (RBT)", pdecAmountRBT);
                                lRecPurchRebateEntry.Validate("Amount (DOC)", pdecAmountDOC);
                            end;
                            lRecPurchRebateEntry."Pay-to Vendor No." := lrecVendor."Pay-to Vendor No.";
                            if lRecPurchRebateEntry."Pay-to Vendor No." = '' then
                                lRecPurchRebateEntry."Pay-to Vendor No." := lrecVendor."No.";
                            lRecPurchRebateEntry."Buy-from Vendor No." := lrecVendor."No.";
                            lRecPurchRebateEntry."Order Address Code" := '';
                            lRecPurchRebateEntry."Post-to Vendor No." := GetAccrualVendor(lRecPurchRebateHeader.Code,
                                                                              lRecPurchRebateEntry."Buy-from Vendor No.",
                                                                              lRecPurchRebateEntry."Pay-to Vendor No.");

                            lRecPurchRebateEntry.Insert(true);
                            //end
                        end;

                        //<ENRE1.00>
                        if (lRecPurchRebateHeader."Rebate Type" = lRecPurchRebateHeader."Rebate Type"::"Sales-Based") or
                          (lRecPurchRebateHeader."Sales Profit Modifier") then begin

                            lfrfRbtDocType := prrfLine.Field(1);
                            if (Format(lfrfRbtDocType.Value) <> '3') and (Format(lfrfRbtDocType.Value) <> '5') then begin
                                lintEntryNo := 1;


                                if lrecSalesProfitMod.FindLast then
                                    lintEntryNo := lrecSalesProfitMod."Entry No." + 1;

                                lrecSalesProfitMod.Init;
                                lrecSalesProfitMod."Entry No." := lintEntryNo;
                                lfrfFieldRef := prrfLine.Field(1);
                                lrecSalesProfitMod."Document Type" := lfrfFieldRef.Value;

                                lfrfFieldRef := prrfLine.Field(3);
                                lrecSalesProfitMod."Document No." := lfrfFieldRef.Value;
                                lfrfFieldRef := prrfLine.Field(4);
                                lrecSalesProfitMod."Document Line No." := lfrfFieldRef.Value;

                                lrecSalesProfitMod."Source Type" := lrecSalesProfitMod."Source Type"::"Purchase Rebate";
                                lrecSalesProfitMod."Source No." := lRecPurchRebateHeader.Code;

                                lfrfRbtDocType := prrfLine.Field(1);
                                lrecSalesProfitMod.Validate("Amount (LCY)", pdecAmountLCY);
                                lrecSalesProfitMod.Validate(Amount, pdecAmountDOC);

                                lrecSalesProfitMod.Insert;
                            end;
                        end;
                        //</ENRE1.00>

                    end;
                DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line":
                    begin
                        lRecPurchRebateHeader.Get(pcodRebateCode);
                        if lRecPurchRebateHeader."Rebate Type" = lRecPurchRebateHeader."Rebate Type"::"Sales-Based" then begin
                            lintEntryNo := 1;
                            if lrecPostedRebateEntry2.FindLast then
                                lintEntryNo := lrecPostedRebateEntry2."Entry No." + 1;
                            lrecPostedRebateEntry.Init;
                            lrecPostedRebateEntry."Entry No." := lintEntryNo;
                            lrecPostedRebateEntry."Functional Area" := lrecPostedRebateEntry."Functional Area"::Purchase;
                            lrecVendor.Get(lRecPurchRebateHeader."Apply-To Vendor No.");
                            lrecItem.Get(pcodItemNo);
                            case lintTableNo of
                                DATABASE::"Sales Invoice Line":
                                    begin
                                        lrecPostedRebateEntry."Source Type" :=
                                          lrecPostedRebateEntry."Source Type"::"Posted Invoice";
                                    end;
                                DATABASE::"Sales Cr.Memo Line":
                                    begin
                                        lrecPostedRebateEntry."Source Type" :=
                                          lrecPostedRebateEntry."Source Type"::"Posted Cr. Memo";
                                    end;
                            end;
                            lfrfFieldRef := prrfLine.Field(3);
                            lrecPostedRebateEntry."Source No." := lfrfFieldRef.Value;
                            lfrfFieldRef := prrfLine.Field(4);
                            lrecPostedRebateEntry."Source Line No." := lfrfFieldRef.Value;
                            lrecPostedRebateEntry."Posting Date" := lRecPurchRebateHeader."Start Date";
                            lrecPostedRebateEntry.Validate("Rebate Code", lRecPurchRebateHeader.Code);
                            lrecPostedRebateEntry.Validate("Item No.", lrecItem."No.");
                            case lintTableNo of
                                DATABASE::"Sales Invoice Line":
                                    begin
                                        lrecPostedRebateEntry.Validate("Amount (LCY)", pdecAmountLCY);
                                        lrecPostedRebateEntry.Validate("Amount (RBT)", pdecAmountRBT);
                                        lrecPostedRebateEntry.Validate("Amount (DOC)", pdecAmountDOC);
                                    end;
                                DATABASE::"Sales Cr.Memo Line":
                                    begin
                                        lrecPostedRebateEntry.Validate("Amount (LCY)", -1 * pdecAmountLCY);
                                        lrecPostedRebateEntry.Validate("Amount (RBT)", -1 * pdecAmountRBT);
                                        lrecPostedRebateEntry.Validate("Amount (DOC)", -1 * pdecAmountDOC);
                                    end;
                            end;
                            lrecPostedRebateEntry."Posted To G/L" := false;
                            lrecPostedRebateEntry."Pay-to Vendor No." := lrecVendor."Pay-to Vendor No.";
                            if lrecPostedRebateEntry."Pay-to Vendor No." = '' then
                                lrecPostedRebateEntry."Pay-to Vendor No." := lrecVendor."No.";
                            lrecPostedRebateEntry."Buy-from Vendor No." := lrecVendor."No.";
                            lrecPostedRebateEntry."Order Address Code" := '';
                            lrecPostedRebateEntry."Paid-by Vendor" := false;
                            lrecPostedRebateEntry."Post-to Vendor No." := GetAccrualVendor(lRecPurchRebateHeader.Code,
                                                                              lrecPostedRebateEntry."Buy-from Vendor No.",
                                                                              lrecPostedRebateEntry."Pay-to Vendor No.");
                            lrecPostedRebateEntry.Insert(true);
                        end;

                        //<ENRE1.00>
                        if (lRecPurchRebateHeader."Rebate Type" = lRecPurchRebateHeader."Rebate Type"::"Sales-Based") or
                          (lRecPurchRebateHeader."Sales Profit Modifier") then begin
                            case lintTableNo of
                                DATABASE::"Sales Invoice Line":
                                    begin

                                        lintEntryNo := 1;
                                        if lrecPostedSalesProfitMod.FindLast then
                                            lintEntryNo := lrecPostedSalesProfitMod."Entry No." + 1;

                                        lrecPostedSalesProfitMod.Init;
                                        lrecPostedSalesProfitMod."Entry No." := lintEntryNo;
                                        lrecPostedSalesProfitMod."Document Type" := lrecPostedSalesProfitMod."Document Type"::Invoice;

                                        lfrfFieldRef := prrfLine.Field(3);
                                        lrecPostedSalesProfitMod."Document No." := lfrfFieldRef.Value;
                                        lfrfFieldRef := prrfLine.Field(4);
                                        lrecPostedSalesProfitMod."Document Line No." := lfrfFieldRef.Value;

                                        lrecPostedSalesProfitMod."Source Type" := lrecPostedSalesProfitMod."Source Type"::"Purchase Rebate";
                                        lrecPostedSalesProfitMod."Source No." := lRecPurchRebateHeader.Code;
                                        lrecPostedSalesProfitMod.Validate("Amount (LCY)", pdecAmountLCY);
                                        lrecPostedSalesProfitMod.Validate(Amount, pdecAmountDOC);

                                        lrecPostedSalesProfitMod.Insert;
                                    end;
                            end;
                        end;
                        //</ENRE1.00>

                    end;
            //</ENRE1.00>
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
            lfrfFieldRef := prrfLine.Field(3);
            precTempRebateEntry."Source No." := lfrfFieldRef.Value;
            precTempRebateEntry.Validate("Source No.");
            lfrfFieldRef := prrfLine.Field(4);
            precTempRebateEntry."Source Line No." := lfrfFieldRef.Value;
            precTempRebateEntry."Currency Code (DOC)" := pcodCurrencyCode;
            lRecPurchRebateHeader.Get(pcodRebateCode);
            precTempRebateEntry."Currency Code (RBT)" := lRecPurchRebateHeader."Currency Code";
            precTempRebateEntry.Validate("Rebate Code", pcodRebateCode);
            precTempRebateEntry.Validate("Item No.", pcodItemNo);
            if lRecPurchRebateHeader."Rebate Type" = lRecPurchRebateHeader."Rebate Type"::"Sales-Based" then begin
                precTempRebateEntry."Buy-from Vendor No." := lRecPurchRebateHeader."Apply-To Vendor No.";
                precTempRebateEntry."Pay-to Vendor No." := lRecPurchRebateHeader."Apply-To Vendor No.";
            end else begin
                lfrfPayToVendor := prrfLine.Field(68);
                precTempRebateEntry."Pay-to Vendor No." := lfrfPayToVendor.Value;
                lfrfBuyFromVendor := prrfLine.Field(2);
                precTempRebateEntry."Buy-from Vendor No." := lfrfBuyFromVendor.Value;
            end;
            case lintTableNo of
                39:
                    begin
                        lfrfRbtDocType := prrfLine.Field(1);
                        precTempRebateEntry."Source Type" := lfrfRbtDocType.Value;
                    end;
                123:
                    begin
                        precTempRebateEntry."Source Type" := precTempRebateEntry."Source Type"::"Posted Invoice";
                        precTempRebateEntry.Validate("Amount (LCY)", pdecAmountLCY);
                        precTempRebateEntry.Validate("Amount (RBT)", pdecAmountRBT);
                        precTempRebateEntry.Validate("Amount (DOC)", pdecAmountDOC);
                        lfrfPostingDate := prrfLine.Field(131);
                        precTempRebateEntry."Posting Date" := lfrfPostingDate.Value;
                    end;
                125:
                    begin
                        precTempRebateEntry."Source Type" := precTempRebateEntry."Source Type"::"Posted Cr. Memo";
                        precTempRebateEntry.Validate("Amount (LCY)", -pdecAmountLCY);
                        precTempRebateEntry.Validate("Amount (RBT)", -pdecAmountRBT);
                        precTempRebateEntry.Validate("Amount (DOC)", -pdecAmountDOC);
                        lfrfPostingDate := prrfLine.Field(131);
                        precTempRebateEntry."Posting Date" := lfrfPostingDate.Value;
                    end;
                //<ENRE1.00>
                DATABASE::"Sales Line":
                    begin
                        if lRecPurchRebateHeader."Rebate Type" = lRecPurchRebateHeader."Rebate Type"::"Sales-Based" then begin
                            lfrfRbtDocType := prrfLine.Field(1);
                            precTempRebateEntry."Source Type" := lfrfRbtDocType.Value;
                        end;
                    end;
                DATABASE::"Sales Invoice Line":
                    begin
                        if lRecPurchRebateHeader."Rebate Type" = lRecPurchRebateHeader."Rebate Type"::"Sales-Based" then begin
                            precTempRebateEntry."Source Type" := precTempRebateEntry."Source Type"::"Posted Invoice";
                            precTempRebateEntry.Validate("Amount (LCY)", pdecAmountLCY);
                            precTempRebateEntry.Validate("Amount (RBT)", pdecAmountRBT);
                            precTempRebateEntry.Validate("Amount (DOC)", pdecAmountDOC);
                            lfrfPostingDate := prrfLine.Field(131);
                            precTempRebateEntry."Posting Date" := lfrfPostingDate.Value;
                        end;
                    end;
                DATABASE::"Sales Cr.Memo Line":
                    begin
                        if lRecPurchRebateHeader."Rebate Type" = lRecPurchRebateHeader."Rebate Type"::"Sales-Based" then begin
                            precTempRebateEntry."Source Type" := precTempRebateEntry."Source Type"::"Posted Cr. Memo";
                            precTempRebateEntry.Validate("Amount (LCY)", -pdecAmountLCY);
                            precTempRebateEntry.Validate("Amount (RBT)", -pdecAmountRBT);
                            precTempRebateEntry.Validate("Amount (DOC)", -pdecAmountDOC);
                            lfrfPostingDate := prrfLine.Field(131);
                            precTempRebateEntry."Posting Date" := lfrfPostingDate.Value;
                        end;
                    end;
            //</ENRE1.00>
            end;
            case precTempRebateEntry."Functional Area" of
                precTempRebateEntry."Functional Area"::Purchase:
                    begin
                        if lrecPurchHeader.Get(precTempRebateEntry."Source Type", precTempRebateEntry."Source No.") then
                            precTempRebateEntry."Order Address Code" := lrecPurchHeader."Ship-to Code";
                    end;
            end;
            precTempRebateEntry."Post-to Vendor No." := GetAccrualVendor(pcodRebateCode,
                                                              precTempRebateEntry."Buy-from Vendor No.",
                                                              precTempRebateEntry."Pay-to Vendor No.");
            if (precTempRebateEntry."Amount (LCY)" <> 0) or
               (precTempRebateEntry."Amount (RBT)" <> 0) or
               (precTempRebateEntry."Amount (DOC)" <> 0) then
                precTempRebateEntry.Insert(true);
        end;
    end;

    //
    procedure CalcPurchDocRebate(prrfHeader: RecordRef; pblnPeriodicCalc: Boolean; pblnForceDocRebatesOnly: Boolean)
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
        DeleteRebateEntryLines(prrfHeader);
        lintTableNo := prrfHeader.Number;
        case lintTableNo of
            38:
                begin
                    lfrfHdrDocType := prrfHeader.Field(1);
                    //<ENRE1.00>
                    grecPurchSetup.Get;
                    if grecPurchSetup."Force Appl On Doc Returns ELA" then begin
                        //</ENRE1.00>
                        if (Format(lfrfHdrDocType.Value) = '3') then begin
                            lfrfFieldRef := prrfHeader.Field(52);
                            lfrfFieldRef2 := prrfHeader.Field(53);

                            if not ((Format(lfrfFieldRef.Value) = '2') and (Format(lfrfFieldRef2.Value) <> '')) then begin
                                exit;
                            end;
                        end;
                    end;//</ENRE1.00>
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lfrfBypassCalc := prrfHeader.Field(14229400);
                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;

                    lrrfLine.Open(39);
                    lfrfLineDocType := lrrfLine.Field(1);
                    lfrfLineDocType.SetFilter(Format(lfrfHdrDocType.Value));
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    lfrfLineQtyInvoiced := lrrfLine.Field(61);
                    lfrfLineQtyInvoiced.SetRange(0);
                end;
            122:
                begin
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lrrfLine.Open(123);
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    lfrfBypassCalc := prrfHeader.Field(14229400);
                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;
                end;
            124:
                begin
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    //<ENRE1.00>
                    grecPurchSetup.Get;
                    if grecPurchSetup."Force Appl On Doc Returns ELA" then begin
                        //</ENRE1.00>
                        lfrfFieldRef := prrfHeader.Field(52);
                        lfrfFieldRef2 := prrfHeader.Field(53);
                        if not ((Format(lfrfFieldRef.Value) = '2') and (Format(lfrfFieldRef2.Value) <> '')) then begin
                            exit;
                        end;
                    end;//<ENRE1.00>
                    lrrfLine.Open(125);
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    lfrfBypassCalc := prrfHeader.Field(23019525); //field not found
                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;
                end;
            else begin
                    Error('');
                end;
        end;

        if pblnForceDocRebatesOnly then
            gRecPurchRebateHeaderFilter.SetFilter("Rebate Type", '%1|%2',
                                             gRecPurchRebateHeaderFilter."Rebate Type"::"Off-Invoice",
                                             gRecPurchRebateHeaderFilter."Rebate Type"::Everyday);
        if lrrfLine.Find('-') then begin
            repeat
                CalcRebate(lrrfLine, pblnPeriodicCalc, lrecTempRebateEntry);
            until lrrfLine.Next = 0;
        end;
    end;

    //
    procedure DeleteRebateEntryLines(prrfHeader: RecordRef)
    var
        lRecPurchRebateEntry: Record "Rebate Entry ELA";
        lintTableNo: Integer;
        lfrfFieldRef: FieldRef;
        lrecSalesProfitModifier: Record "Sales Profit Modifier ELA";
    begin
        lintTableNo := prrfHeader.Number;
        case lintTableNo of
            38:
                begin
                    lfrfFieldRef := prrfHeader.Field(1);
                    lRecPurchRebateEntry.SetFilter("Source Type", Format(lfrfFieldRef.Value));
                end;
        end;
        lfrfFieldRef := prrfHeader.Field(3);
        lRecPurchRebateEntry.SetRange("Source No.", Format(lfrfFieldRef.Value));

        lRecPurchRebateEntry.SetRange("Source Line No.");
        lRecPurchRebateEntry.SetRange("Rebate Code");
        lRecPurchRebateEntry.DeleteAll;

        //<ENRE1.00>
        lrecSalesProfitModifier.SetRange("Document No.", Format(lfrfFieldRef.Value));
        lrecSalesProfitModifier.DeleteAll;
        //</ENRE1.00>
    end;


    procedure DeleteRebateEntry(prrfLine: RecordRef)
    var
        lRecPurchRebateEntry: Record "Rebate Entry ELA";
        lintTableNo: Integer;
        lintLineNo: Integer;
        lfrfFieldRef: FieldRef;
        lrecSalesProfitModifier: Record "Sales Profit Modifier ELA";
    begin
        lintTableNo := prrfLine.Number;
        case lintTableNo of
            39:
                begin
                    lfrfFieldRef := prrfLine.Field(1);
                    lRecPurchRebateEntry.SetFilter("Source Type", Format(lfrfFieldRef.Value));
                end;
        end;
        lfrfFieldRef := prrfLine.Field(3);
        lRecPurchRebateEntry.SetRange("Source No.", Format(lfrfFieldRef.Value));
        lfrfFieldRef := prrfLine.Field(4);
        Evaluate(lintLineNo, Format(lfrfFieldRef.Value));
        lRecPurchRebateEntry.SetRange("Source Line No.", lintLineNo);
        lRecPurchRebateEntry.SetRange("Rebate Code");
        lRecPurchRebateEntry.DeleteAll;

        //<ENRE1.00>
        lfrfFieldRef := prrfLine.Field(3);
        lrecSalesProfitModifier.SetRange("Document No.", Format(lfrfFieldRef.Value));
        lfrfFieldRef := prrfLine.Field(4);
        Evaluate(lintLineNo, Format(lfrfFieldRef.Value));
        lrecSalesProfitModifier.SetRange("Document Line No.", lintLineNo);
        lrecSalesProfitModifier.DeleteAll;
        //</ENRE1.00>
    end;


    procedure SetRebateFilter(var pRecPurchRebateHeaderFilter: Record "Purchase Rebate Header ELA")
    begin
        gRecPurchRebateHeaderFilter.CopyFilters(pRecPurchRebateHeaderFilter);
    end;


    procedure CalcLumpSumRebate(pdteAsOfDate: Date; precRebate: Record "Purchase Rebate Header ELA")
    var
        lrecVendor: Record Vendor;
        lrecTempVendor: Record Vendor temporary;
        lrecItem: Record Item;
        lrecTempItem: Record Item temporary;
        lrecRebateLedger: Record "Rebate Ledger Entry ELA";
        lrecRebateLine: Record "Purchase Rebate Line ELA";
        lrecTempRebateLine: Record "Purchase Rebate Line ELA" temporary;
        lrecRebateLine2: Record "Purchase Rebate Line ELA";
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
        lText001: Label 'Vendor No. %1 is blocked. The distribution for rebate %2 cannot continue.';
    begin
        if precRebate."Rebate Type" <> precRebate."Rebate Type"::"Lump Sum" then
            exit;

        if precRebate.Blocked then
            exit;

        precRebate.TestField("Start Date");

        lintCustCount := 0;

        grecPurchSetup.Get;

        lrecVendor.Reset;
        lrecItem.Reset;
        lrecRebateLedger.Reset;
        lrecRebateLine.Reset;

        lrecTempVendor.Reset;
        lrecTempVendor.DeleteAll;

        lrecTempItem.Reset;
        lrecTempItem.DeleteAll;

        //-- We need to post an entry ONLY if sum of rebate ledger entries is not equal to Rebate Value on rebate card
        lrecRebateLedger.SetCurrentKey("Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Code");

        lrecRebateLedger.SetRange("Functional Area", lrecRebateLedger."Functional Area"::Purchase);
        lrecRebateLedger.SetRange("Source Type", lrecRebateLedger."Source Type"::Vendor);
        lrecRebateLedger.SetRange("Source No.");
        lrecRebateLedger.SetRange("Source Line No.");
        lrecRebateLedger.SetRange("Rebate Code", precRebate.Code);

        lrecRebateLedger.CalcSums("Amount (RBT)");

        if lrecRebateLedger."Amount (RBT)" <> precRebate."Rebate Value" then begin
            //-- Calculate amount to post for this rebate
            ldecRebateValueToPost := precRebate."Rebate Value" - lrecRebateLedger."Amount (RBT)";

            if ldecRebateValueToPost <> 0 then begin
                if grecPurchSetup.
                  "Lump Sum Rbt Blk Vend. Act ELA" = grecPurchSetup."Lump Sum Rbt Blk Vend. Act ELA"::Skip then
                    lrecVendor.SetRange(Blocked, lrecVendor.Blocked::" ");

                if precRebate."Apply-To Vendor No." <> '' then begin
                    lrecVendor.SetRange("No.", precRebate."Apply-To Vendor No.");
                end else
                    if precRebate."Apply-To Vendor Group Code" <> '' then begin
                        lrecVendor.SetRange("Rebate Group Code ELA", precRebate."Apply-To Vendor Group Code");
                    end;

                if lrecVendor.FindSet then begin
                    repeat
                        lrecTempVendor.Init;
                        lrecTempVendor.TransferFields(lrecVendor);
                        if lrecTempVendor.Insert then;
                    until lrecVendor.Next = 0;
                end;

                //---------------------------------------------------------------------------------------------------------------------------
                //---------------------------------------------------------------------------------------------------------------------------
                //-----------------DO NOT USE LRECVENDOR PAST THIS POINT. USE ONLY THE LRECTEMPVENDOR TABLE FOR PERFORMANCE!!!-----------
                //---------------------------------------------------------------------------------------------------------------------------
                //---------------------------------------------------------------------------------------------------------------------------
                if lrecTempVendor.IsEmpty then
                    exit;

                lintCustCount := lrecTempVendor.Count;

                //-- Load up rebate lines into temp table to avoid multiple reads back to server
                lrecRebateLine.Reset;
                lrecRebateLine.SetRange("Purchase Rebate Code", precRebate.Code);

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

                if lintCustCount <> 0 then begin
                    if grecPurchSetup."Lump Sum Rbt Distribution ELA" =
                      grecPurchSetup."Lump Sum Rbt Distribution ELA"::"Vendor-Item" then begin

                        ltxtItemNoFilter := '';
                        ltxtRebateGroupFilter := '';
                        ltxtItemCategoryFilter := '';

                        //-- If no item details exist, then it applies to all items
                        lrecTempRebateLine.Reset;
                        lrecTempRebateLine.SetRange("Purchase Rebate Code", precRebate.Code);
                        lrecTempRebateLine.SetRange("Line No.");
                        lrecTempRebateLine.SetRange(Source, lrecTempRebateLine.Source::Item);

                        if lrecTempRebateLine.FindSet then begin
                            repeat
                                case lrecTempRebateLine.Type of
                                    lrecTempRebateLine.Type::"No.":
                                        begin
                                            if not lrecTempRebateLine.Include then begin
                                                lrecRebateLine2.SetRange("Purchase Rebate Code", lrecTempRebateLine."Purchase Rebate Code");
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
                                                            lrecRebateLine2.SetRange("Purchase Rebate Code", lrecTempRebateLine."Purchase Rebate Code");
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
                                                            lrecRebateLine2.SetRange("Purchase Rebate Code", lrecTempRebateLine."Purchase Rebate Code");
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

                        if grecPurchSetup."Items Req. on Lump Sum Rbt ELA" then begin
                            if lintItemCount = 0 then
                                Error(ljxText000, precRebate.Code);
                        end;

                        if (lintCustCount <> 0) and (lintItemCount <> 0) then begin
                            ldecRebateValuePerEntry := Round(ldecRebateValueToPost / lintCustCount / lintItemCount, 0.00001);

                            if lrecTempVendor.FindSet then begin
                                lrecRebateLedger.Reset;

                                if lrecRebateLedger.FindLast then
                                    lintEntryNo := lrecRebateLedger."Entry No." + 1
                                else
                                    lintEntryNo := 1;

                                repeat
                                    if lrecTempItem.FindSet then begin
                                        if grecPurchSetup."Lump Sum Rbt Blk Vend. Act ELA" = grecPurchSetup."Lump Sum Rbt Blk Vend. Act ELA"::Error then
                                            if lrecVendor.Blocked > 0 then
                                                Error(lText001, lrecVendor."No.", precRebate.Code);
                                        repeat
                                            lrecRebateLedger.Init;
                                            lrecRebateLedger."Entry No." := lintEntryNo;
                                            lrecRebateLedger."Functional Area" := lrecRebateLedger."Functional Area"::Purchase;
                                            lrecRebateLedger."Source Type" := lrecRebateLedger."Source Type"::Vendor;
                                            lrecRebateLedger."Source No." := lrecVendor."No.";
                                            lrecRebateLedger."Source Line No." := 0;
                                            lrecRebateLedger."Posting Date" := precRebate."Start Date";

                                            lrecRebateLedger.Validate("Rebate Code", precRebate.Code);
                                            lrecRebateLedger.Validate("Item No.", lrecItem."No.");

                                            lrecRebateLedger.Validate("Amount (LCY)", lrecCurrExchange.ExchangeAmtFCYToFCY(
                                                                                     precRebate."Start Date",
                                                                                     precRebate."Currency Code", '', ldecRebateValuePerEntry));
                                            lrecRebateLedger.Validate("Amount (RBT)", ldecRebateValuePerEntry);
                                            lrecRebateLedger.Validate("Amount (DOC)", 0);

                                            lrecRebateLedger."Posted To G/L" := false;

                                            lrecRebateLedger."Pay-to Vendor No." := lrecVendor."Pay-to Vendor No.";

                                            if lrecRebateLedger."Pay-to Vendor No." = '' then
                                                lrecRebateLedger."Pay-to Vendor No." := lrecVendor."No.";

                                            lrecRebateLedger."Buy-from Vendor No." := lrecVendor."No.";
                                            lrecRebateLedger."Order Address Code" := '';

                                            lrecRebateLedger."Paid-by Vendor" := false;
                                            lrecRebateLedger."Post-to Vendor No." := GetAccrualVendor(precRebate.Code,
                                                                                              lrecRebateLedger."Buy-from Vendor No.",
                                                                                              lrecRebateLedger."Pay-to Vendor No.");
                                            lrecRebateLedger.Insert(true);

                                            lintEntryNo += 1;
                                            ldecRebateValueToPost -= ldecRebateValuePerEntry;
                                        until lrecTempItem.Next = 0;
                                    end;
                                until (lrecTempVendor.Next = 0) or (ldecRebateValueToPost = 0);

                                //-- Add remainder to rebate ledger entry created
                                if ldecRebateValueToPost <> 0 then begin
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
                        if lintCustCount <> 0 then begin
                            ldecRebateValuePerEntry := Round(ldecRebateValueToPost / lintCustCount, 0.00001);

                            if lrecTempVendor.FindSet then begin
                                if grecPurchSetup."Lump Sum Rbt Blk Vend. Act ELA" = grecPurchSetup."Lump Sum Rbt Blk Vend. Act ELA"::Error then
                                    if lrecVendor.Blocked > 0 then
                                        Error(lText001, lrecVendor."No.", precRebate.Code);

                                lrecRebateLedger.Reset;

                                if lrecRebateLedger.FindLast then
                                    lintEntryNo := lrecRebateLedger."Entry No." + 1
                                else
                                    lintEntryNo := 1;

                                repeat
                                    lrecRebateLedger.Init;

                                    lrecRebateLedger."Entry No." := lintEntryNo;
                                    lrecRebateLedger."Functional Area" := lrecRebateLedger."Functional Area"::Purchase;
                                    lrecRebateLedger."Source Type" := lrecRebateLedger."Source Type"::Vendor;
                                    lrecRebateLedger."Source No." := lrecVendor."No.";
                                    lrecRebateLedger."Source Line No." := 0;
                                    lrecRebateLedger."Posting Date" := precRebate."Start Date";

                                    lrecRebateLedger.Validate("Rebate Code", precRebate.Code);

                                    lrecRebateLedger.Validate("Amount (LCY)", lrecCurrExchange.ExchangeAmtFCYToFCY(
                                                                             precRebate."Start Date",
                                                                             precRebate."Currency Code", '', ldecRebateValuePerEntry));
                                    lrecRebateLedger.Validate("Amount (RBT)", ldecRebateValuePerEntry);
                                    lrecRebateLedger.Validate("Amount (DOC)", 0);

                                    lrecRebateLedger."Posted To G/L" := false;

                                    lrecRebateLedger."Pay-to Vendor No." := lrecVendor."Pay-to Vendor No.";

                                    if lrecRebateLedger."Pay-to Vendor No." = '' then
                                        lrecRebateLedger."Pay-to Vendor No." := lrecVendor."No.";

                                    lrecRebateLedger."Buy-from Vendor No." := lrecVendor."No.";
                                    lrecRebateLedger."Order Address Code" := '';

                                    lrecRebateLedger."Paid-by Vendor" := false;
                                    lrecRebateLedger."Post-to Vendor No." := GetAccrualVendor(precRebate.Code,
                                                                                      lrecRebateLedger."Buy-from Vendor No.",
                                                                                      lrecRebateLedger."Pay-to Vendor No.");
                                    lrecRebateLedger.Insert(true);

                                    lintEntryNo += 1;
                                    ldecRebateValueToPost -= ldecRebateValuePerEntry;
                                until (lrecTempVendor.Next = 0) or (ldecRebateValueToPost = 0);

                                //-- Add remainder to rebate ledger entry created
                                if ldecRebateValueToPost <> 0 then begin
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


    procedure GetAccrualVendor(pcodRebateCode: Code[20]; pcodBuyFromVendor: Code[20]; pcodPayToVendor: Code[20]): Code[20]
    var
        lRecPurchRebate: Record "Purchase Rebate Header ELA";
        lrecVendor: Record Vendor;
        lrecVendBuyGrp: Record "Vendor Buying Group ELA";
    begin
        if (pcodRebateCode = '') or (pcodBuyFromVendor = '') or (pcodPayToVendor = '') then
            exit;
        if not lRecPurchRebate.Get(pcodRebateCode) then
            exit;
        if lRecPurchRebate."Post to Vendor Buying Group" then begin
            lrecVendor.Get(pcodBuyFromVendor);
            if lrecVendor."Vendor Buying Group Code ELA" <> '' then begin
                lrecVendBuyGrp.Get(lrecVendor."Vendor Buying Group Code ELA");
                lrecVendBuyGrp.TestField("Rebate Accrual Vendor No.");
                exit(lrecVendBuyGrp."Rebate Accrual Vendor No.");
            end else begin
                exit(pcodPayToVendor);
            end;
        end else begin
            exit(pcodPayToVendor);
        end;
    end;


    procedure AccrueRebateFromVendor(var pRecPurchRebateLedgEntry: Record "Rebate Ledger Entry ELA"; pcodVendNo: Code[20])
    var
        lrecGenJnlLine: Record "Gen. Journal Line";
        lrecGLEntry: Record "G/L Entry";
        lrecVendLedgEntry: Record "Vendor Ledger Entry";
        lrecSourceCodeSetup: Record "Source Code Setup";
        lrecTEMPVendLedgEntry: Record "Vendor Ledger Entry" temporary;
        lRecPurchRebateHeader: Record "Purchase Rebate Header ELA";
        lrecCurrency: Record Currency;
        lrecGLSetup: Record "General Ledger Setup";
        lRecPurchRebateLedgEntry: Record "Rebate Ledger Entry ELA";
        lrecPurchSetup: Record "Purchases & Payables Setup";
        lrecJnlBatch: Record "Gen. Journal Batch";
        lfrmPostRebate: Page "Post Rebate To Vendor ELA";
        lPagPostRebate: Page "Post Rebate To Vendor ELA";
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
        if pcodVendNo = '' then
            exit;
        lrecSourceCodeSetup.Get;
        lrecGLSetup.Get;
        lrecPurchSetup.Get;
        lblnPromoJobSourceSetupCheck := false;
        ldecAmount := 0;
        Clear(lcduNoSeriesMgt);
        Clear(lrecTEMPVendLedgEntry);
        lrecTEMPVendLedgEntry.DeleteAll;
        lrecPurchSetup.TestField("Rebate Document Nos. ELA");
        lcodInitDocNo := lcduNoSeriesMgt.GetNextNo(lrecPurchSetup."Rebate Document Nos. ELA", WorkDate, false);
        if not gblnUseDefaultPostingValues then begin
            lPagPostRebate.SetValues(lcodInitDocNo, WorkDate, 0);
            lPagPostRebate.LookupMode(true);
            if ACTION::LookupOK = lPagPostRebate.RunModal then begin
                lPagPostRebate.GetValues(lcodDocNo, ldtePostingDate, loptAction);
            end else begin
                exit;
            end;
        end else begin
            lcodDocNo := lcodInitDocNo;
            ldtePostingDate := WorkDate;
            loptAction := loptAction::"Post Only";
        end;
        if lcodInitDocNo = lcodDocNo then
            lcduNoSeriesMgt.SaveNoSeries;
        pRecPurchRebateLedgEntry.SetCurrentKey("Post-to Vendor No.", "Rebate Code");
        pRecPurchRebateLedgEntry.SetRange("Post-to Vendor No.", pcodVendNo);
        pRecPurchRebateLedgEntry.SetRange("Rebate Code");
        if pRecPurchRebateLedgEntry.Find('-') then begin
            if loptAction = loptAction::"Post and Create Refund" then begin
            end;
            if GuiAllowed then begin
                ldlgWindow.Open(lText001);
            end;
            lintCount := pRecPurchRebateLedgEntry.Count;
            lintCounter := 0;
            repeat
                lintCounter += 1;
                if GuiAllowed then begin
                    ldlgWindow.Update(1, lintCounter);
                    ldlgWindow.Update(2, Round(lintCounter / lintCount) * 10000);
                end;
                lrecCurrency.InitRoundingPrecision;
                lRecPurchRebateHeader.Get(pRecPurchRebateLedgEntry."Rebate Code");
                lRecPurchRebateHeader.TestField(Blocked, false);
                if Round(-(pRecPurchRebateLedgEntry."Amount (LCY)"), lrecCurrency."Amount Rounding Precision") <> 0 then begin
                    pRecPurchRebateLedgEntry.TestField("Post-to Vendor No.");
                    lrecGenJnlLine.Init;
                    lrecGenJnlLine."System-Created Entry" := true;
                    lrecGenJnlLine."Posting Date" := ldtePostingDate;
                    lrecGenJnlLine."Document No." := lcodDocNo;
                    lrecGenJnlLine."Account Type" := lrecGenJnlLine."Account Type"::"G/L Account";
                    lrecGenJnlLine."Account No." := lRecPurchRebateHeader."Offset G/L Account No.";
                    lrecGenJnlLine."Bal. Account Type" := lrecGenJnlLine."Bal. Account Type"::Vendor;
                    lrecGenJnlLine."Bal. Account No." := pRecPurchRebateLedgEntry."Post-to Vendor No.";
                    lrecGenJnlLine.Description := pRecPurchRebateLedgEntry."Rebate Description";
                    lrecGenJnlLine."Rebate Code ELA" := pRecPurchRebateLedgEntry."Rebate Code";
                    lrecGenJnlLine."Rebate Source Type ELA" := pRecPurchRebateLedgEntry."Source Type";
                    lrecGenJnlLine."Rebate Source No. ELA" := pRecPurchRebateLedgEntry."Source No.";
                    lrecGenJnlLine."Rebate Source Line No. ELA" := pRecPurchRebateLedgEntry."Source Line No.";
                    lrecGenJnlLine."Rebate Document No. ELA" := pRecPurchRebateLedgEntry."Rebate Document No.";
                    lrecGenJnlLine."Posted Rebate Entry No. ELA" := pRecPurchRebateLedgEntry."Entry No.";
                    lrecGenJnlLine."Rebate Accrual Vendor No. ELA" := pRecPurchRebateLedgEntry."Post-to Vendor No.";
                    lrecGenJnlLine.Validate("Rebate Vendor No. ELA", pRecPurchRebateLedgEntry."Buy-from Vendor No.");
                    lrecGenJnlLine.Validate("Rebate Item No. ELA", pRecPurchRebateLedgEntry."Item No.");
                    lrecGenJnlLine."Source Code" := lrecSourceCodeSetup.Purchases;
                    lrecGenJnlLine."Bill-to/Pay-to No." := pRecPurchRebateLedgEntry."Post-to Vendor No.";
                    lrecGenJnlLine."Ship-to/Order Address Code" := pRecPurchRebateLedgEntry."Order Address Code";
                    lrecGenJnlLine."Sell-to/Buy-from No." := pRecPurchRebateLedgEntry."Buy-from Vendor No.";
                    //<ENRE1.00>
                    lrecGenJnlLine."External Document No." := pRecPurchRebateLedgEntry."Claim Reference No.";

                    //</ENRE1.00>
                    if pRecPurchRebateLedgEntry."Amount (DOC)" = 0 then begin
                        lrecGenJnlLine.Validate("Currency Code", '');
                        lrecGenJnlLine.Validate(Amount, -pRecPurchRebateLedgEntry."Amount (LCY)");
                    end else begin
                        lrecGenJnlLine.Validate("Currency Code", pRecPurchRebateLedgEntry."Currency Code (DOC)");
                        lrecGenJnlLine.Validate(Amount, -pRecPurchRebateLedgEntry."Amount (DOC)");
                    end;

                    lrecGenJnlLine."Shortcut Dimension 1 Code" := '';
                    lrecGenJnlLine."Shortcut Dimension 2 Code" := '';

                    lrecGLEntry.SetRange("G/L Account No.", lrecGenJnlLine."Account No.");
                    lrecGLEntry.SetRange("Posted Rebate Entry No. ELA", pRecPurchRebateLedgEntry."Entry No.");

                    if not lrecGLEntry.FindFirst then
                        Error(lText000, pRecPurchRebateLedgEntry."Entry No.", lrecGenJnlLine."Account No.");

                    lrecGenJnlLine."Dimension Set ID" := lrecGLEntry."Dimension Set ID";

                    DimMgt.UpdateGlobalDimFromDimSetID(lrecGenJnlLine."Dimension Set ID",
                      lrecGenJnlLine."Shortcut Dimension 1 Code", lrecGenJnlLine."Shortcut Dimension 2 Code");

                    lcduGenJnlPostLine.RunWithCheck(lrecGenJnlLine);

                    lRecPurchRebateLedgEntry.Get(pRecPurchRebateLedgEntry."Entry No.");
                    lRecPurchRebateLedgEntry."Posted To Vendor" := true;
                    lRecPurchRebateLedgEntry.Modify;

                    if loptAction = loptAction::"Post and Create Refund" then begin
                        lrecVendLedgEntry.FindLast;
                        lrecTEMPVendLedgEntry.Init;
                        lrecTEMPVendLedgEntry."Entry No." := lrecVendLedgEntry."Entry No.";
                        lrecTEMPVendLedgEntry.Insert;
                    end;
                end else begin
                    lRecPurchRebateLedgEntry.Get(pRecPurchRebateLedgEntry."Entry No.");
                    lRecPurchRebateLedgEntry."Posted To Vendor" := true;
                    lRecPurchRebateLedgEntry."Paid-by Vendor" := true;
                    lRecPurchRebateLedgEntry.Modify;
                end;
            until pRecPurchRebateLedgEntry.Next = 0;
            if GuiAllowed then
                ldlgWindow.Close;
            if loptAction = loptAction::"Post and Create Refund" then begin
                if lrecTEMPVendLedgEntry.FindSet then begin
                    repeat
                        lrecVendLedgEntry.Get(lrecTEMPVendLedgEntry."Entry No.");
                        lrecVendLedgEntry.CalcFields("Remaining Amount");
                        if lrecVendLedgEntry."Remaining Amount" <> 0 then begin
                            lrecVendLedgEntry."Applies-to ID" := lcodDocNo;
                            lrecVendLedgEntry."Amount to Apply" := lrecVendLedgEntry."Remaining Amount";
                            lrecVendLedgEntry.Modify;
                            ldecAmount += -lrecVendLedgEntry."Remaining Amount";
                        end;
                    until lrecTEMPVendLedgEntry.Next = 0;
                    lrecPurchSetup.TestField("Rbt Refund Jnl. Template ELA");
                    lrecPurchSetup.TestField("Rbt Refund Journal Batch ELA");
                    lrecJnlBatch.Get(lrecPurchSetup."Rbt Refund Jnl. Template ELA", lrecPurchSetup."Rbt Refund Journal Batch ELA");
                    lrecJnlBatch.TestField("No. Series", '');
                    lrecGenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Line No.");
                    lrecGenJnlLine.SetRange("Journal Template Name", lrecPurchSetup."Rbt Refund Jnl. Template ELA");
                    lrecGenJnlLine.SetRange("Journal Batch Name", lrecPurchSetup."Rbt Refund Journal Batch ELA");
                    lrecGenJnlLine.SetRange("Line No.");
                    lrecGenJnlLine.LockTable;
                    if lrecGenJnlLine.FindLast then
                        lintLineNo := lrecGenJnlLine."Line No."
                    else
                        lintLineNo := 0;
                    lrecGenJnlLine.Init;
                    lrecGenJnlLine."Journal Template Name" := lrecPurchSetup."Rbt Refund Jnl. Template ELA";
                    lrecGenJnlLine."Journal Batch Name" := lrecPurchSetup."Rbt Refund Journal Batch ELA";
                    lrecGenJnlLine."Line No." := lintLineNo + 10000;
                    lrecGenJnlLine.Insert(true);

                    lrecGenJnlLine.Validate("Posting Date", ldtePostingDate);
                    lrecGenJnlLine.Validate("Document Type", lrecGenJnlLine."Document Type"::Refund);
                    lrecGenJnlLine.Validate("Document No.", lcodDocNo);

                    lrecGenJnlLine.Validate("Account Type", lrecGenJnlLine."Account Type"::Vendor);
                    lrecGenJnlLine.Validate("Account No.", pRecPurchRebateLedgEntry."Post-to Vendor No.");
                    lrecGenJnlLine.Validate("Bal. Account Type", lrecJnlBatch."Bal. Account Type");
                    lrecGenJnlLine.Validate("Bal. Account No.", lrecJnlBatch."Bal. Account No.");
                    lrecGenJnlLine.Validate("Reason Code", lrecJnlBatch."Reason Code");
                    lrecGenJnlLine."Source Code" := lrecSourceCodeSetup."Payment Journal";
                    lrecGenJnlLine.Validate("Applies-to ID", lcodDocNo);
                    lrecGenJnlLine.Validate("Currency Code", lrecVendLedgEntry."Currency Code");
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
    end;


    procedure SkipDialogMode(pbln: Boolean)
    begin
        gblnUseDefaultPostingValues := pbln;
    end;


    procedure CalcPurchDocLineRebate(prrfHeader: RecordRef; prrfLine: RecordRef; pblnPeriodicCalc: Boolean; pblnForceDocRebatesOnly: Boolean; pblnForceCreditApplyToCheck: Boolean)
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
        DeleteRebateEntry(prrfLine);
        lintTableNo := prrfHeader.Number;
        case lintTableNo of
            38:
                begin
                    lfrfHdrDocType := prrfHeader.Field(1);
                    //<ENRE1.00>
                    grecPurchSetup.Get;
                    if grecPurchSetup."Force Appl On Doc Returns ELA" then begin
                        //</ENRE1.00>
                        if pblnForceCreditApplyToCheck = true then begin
                            if (Format(lfrfHdrDocType.Value) = '3') then begin
                                lfrfFieldRef := prrfHeader.Field(52);
                                lfrfFieldRef2 := prrfHeader.Field(53);
                                if not ((Format(lfrfFieldRef.Value) = '2') and (Format(lfrfFieldRef2.Value) <> '')) then begin
                                    exit;
                                end;
                            end;
                        end;
                    end; //<ENRE1.00>
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lfrfBypassCalc := prrfHeader.Field(14229400);
                    lfrfLineDocLineNoValue := prrfLine.Field(4);
                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;
                    lrrfLine.Open(39);
                    lfrfLineDocType := lrrfLine.Field(1);
                    lfrfLineDocType.SetFilter(Format(lfrfHdrDocType.Value));
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    lfrfLineDocLineNo := lrrfLine.Field(4);
                    lfrfLineDocLineNo.SetFilter(Format(lfrfLineDocLineNoValue.Value));
                    lfrfLineQtyInvoiced := lrrfLine.Field(61);
                    lfrfLineQtyInvoiced.SetRange(0);
                end;
            122:
                begin
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lfrfLineDocLineNoValue := prrfLine.Field(4);
                    lrrfLine.Open(123);
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    lfrfLineDocLineNo := lrrfLine.Field(4);
                    lfrfLineDocLineNo.SetFilter(Format(lfrfLineDocLineNoValue.Value));
                    lfrfBypassCalc := prrfHeader.Field(14229400);
                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;
                end;
            124:
                begin
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lfrfLineDocLineNoValue := prrfLine.Field(4);
                    //<ENRE1.00>
                    grecPurchSetup.Get;
                    if grecPurchSetup."Force Appl On Doc Returns ELA" then begin
                        //</ENRE1.00>
                        if pblnForceCreditApplyToCheck = true then begin
                            lfrfFieldRef := prrfHeader.Field(6601);
                            lfrfFieldRef2 := prrfHeader.Field(52);
                            lfrfFieldRef3 := prrfHeader.Field(53);
                            //<ENRE1.00>
                            if not (
                              //</ENRE1.00>
                              ((Format(lfrfFieldRef2.Value) = '2') and (Format(lfrfFieldRef3.Value) <> ''))) then begin
                                exit;
                            end;
                        end;
                    end; //<ENRE1.00>
                    lrrfLine.Open(125);
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    lfrfLineDocLineNo := lrrfLine.Field(4);
                    lfrfLineDocLineNo.SetFilter(Format(lfrfLineDocLineNoValue.Value));
                    lfrfBypassCalc := prrfHeader.Field(23019525); //field not found "Bypass Rebate Calculation"
                    if (Format(lfrfBypassCalc.Value) = 'Yes') then
                        exit;
                end;
            else begin
                    Error('');
                end;
        end;

        if pblnForceDocRebatesOnly then
            gRecPurchRebateHeaderFilter.SetFilter("Rebate Type", '%1|%2',
                                             gRecPurchRebateHeaderFilter."Rebate Type"::"Off-Invoice",
                                             gRecPurchRebateHeaderFilter."Rebate Type"::Everyday);
        if lrrfLine.Find('-') then
            repeat
                CalcRebate(lrrfLine, pblnPeriodicCalc, lrecTempRebateEntry);
            until lrrfLine.Next = 0;
    end;


    procedure CalcAmount(var precRLE: Record "Rebate Ledger Entry ELA"; pblnIncludeTax: Boolean): Decimal
    var
        lrecPurchInvLine: Record "Purch. Inv. Line";
        lrecPurchCrMemoLine: Record "Purch. Cr. Memo Line";
        lRecPurchRebateLedgerEntry: Record "Rebate Ledger Entry ELA";
    begin
        case precRLE."Source Type" of
            precRLE."Source Type"::"Posted Invoice", precRLE."Source Type"::"Posted Cr. Memo":
                begin
                    case precRLE."Source Type" of
                        precRLE."Source Type"::"Posted Invoice":
                            begin
                                if lrecPurchInvLine.Get(precRLE."Source No.", precRLE."Source Line No.") then begin
                                    if pblnIncludeTax then begin
                                        exit(lrecPurchInvLine."Amount Including VAT");
                                    end else begin
                                        exit(lrecPurchInvLine.Amount);
                                    end;
                                end;
                            end;
                        precRLE."Source Type"::"Posted Cr. Memo":
                            begin
                                if lrecPurchCrMemoLine.Get(precRLE."Source No.", precRLE."Source Line No.") then begin
                                    if pblnIncludeTax then begin
                                        exit(lrecPurchCrMemoLine."Amount Including VAT");
                                    end else begin
                                        exit(lrecPurchCrMemoLine.Amount);
                                    end;
                                end;
                            end;
                    end;
                end;
            else
                exit(0);
        end;
    end;


    procedure CalcRebateAmount(var precRLE: Record "Rebate Ledger Entry ELA"; poptAmountType: Option LCY,RBT,DOC): Decimal
    var
        lrecPurchInvLine: Record "Purch. Inv. Line";
        lrecPurchCrMemoLine: Record "Purch. Cr. Memo Line";
        lRecPurchRebateLedgerEntry: Record "Rebate Ledger Entry ELA";
    begin
        case precRLE."Source Type" of
            precRLE."Source Type"::"Posted Invoice", precRLE."Source Type"::"Posted Cr. Memo":
                begin
                    lRecPurchRebateLedgerEntry.SetCurrentKey("Source Type", "Source No.", "Source Line No.",
                                          "Post-to Vendor No.", "Rebate Code", "Posted To G/L", "Posted To Vendor", "G/L Posting Only");
                    lRecPurchRebateLedgerEntry.SetRange("Source Type", precRLE."Source Type");
                    lRecPurchRebateLedgerEntry.SetRange("Source No.", precRLE."Source No.");
                    lRecPurchRebateLedgerEntry.SetRange("Source Line No.", precRLE."Source Line No.");
                    lRecPurchRebateLedgerEntry.SetRange("Post-to Vendor No.", precRLE."Post-to Vendor No.");
                    lRecPurchRebateLedgerEntry.SetRange("Rebate Code", precRLE."Rebate Code");
                    lRecPurchRebateLedgerEntry.SetRange("Posted To G/L", true);
                    lRecPurchRebateLedgerEntry.SetRange("Posted To Vendor", false);
                    lRecPurchRebateLedgerEntry.SetRange("G/L Posting Only", true);
                    lRecPurchRebateLedgerEntry.CalcSums(lRecPurchRebateLedgerEntry."Amount (LCY)", lRecPurchRebateLedgerEntry."Amount (RBT)",
                                                    lRecPurchRebateLedgerEntry."Amount (DOC)");
                    case poptAmountType of
                        poptAmountType::LCY:
                            begin
                                exit(lRecPurchRebateLedgerEntry."Amount (LCY)");
                            end;
                        poptAmountType::RBT:
                            begin
                                exit(lRecPurchRebateLedgerEntry."Amount (RBT)");
                            end;
                        poptAmountType::DOC:
                            begin
                                exit(lRecPurchRebateLedgerEntry."Amount (DOC)");
                            end;
                    end;
                end;
            else
                exit(0);
        end;
    end;


    procedure CalcSalesBasedPurchRebate(prrfHeader: RecordRef; pblnPeriodicCalc: Boolean; pblnForceCreditApplyToCheck: Boolean)
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
        DeleteSBRebateEntryLines(prrfHeader);
        lintTableNo := prrfHeader.Number;
        case lintTableNo of
            DATABASE::"Sales Header":
                begin
                    lfrfHdrDocType := prrfHeader.Field(1);
                    //<ENRE1.00>
                    grecPurchSetup.Get;
                    if grecPurchSetup."Force Appl On Doc Returns ELA" then begin
                        //</ENRE1.00>
                        if pblnForceCreditApplyToCheck = true then begin
                            if (Format(lfrfHdrDocType.Value) = '3') then begin
                                lfrfFieldRef := prrfHeader.Field(52);
                                lfrfFieldRef2 := prrfHeader.Field(53);
                                if not ((Format(lfrfFieldRef.Value) = '2') and (Format(lfrfFieldRef2.Value) <> '')) then begin
                                    exit;
                                end;
                            end;
                        end;
                    end;//<ENRE1.00>
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lrrfLine.Open(37);
                    lfrfLineDocType := lrrfLine.Field(1);
                    lfrfLineDocType.SetFilter(Format(lfrfHdrDocType.Value));
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    //<ENRE1.00> - deleted code
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    lrrfLine.Open(113);
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lfrfLineDocLineNoValue := lrrfLine.Field(4);
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                    lfrfLineDocLineNo := lrrfLine.Field(4);
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    lrrfLine.Open(115);
                    lfrfHdrDocNo := prrfHeader.Field(3);
                    lfrfLineDocLineNoValue := lrrfLine.Field(4);
                    //<ENRE1.00>
                    grecPurchSetup.Get;
                    if grecPurchSetup."Force Appl On Doc Returns ELA" then begin
                        //</ENRE1.00>
                        if pblnForceCreditApplyToCheck = true then begin
                            lfrfFieldRef := prrfHeader.Field(6601);
                            lfrfFieldRef2 := prrfHeader.Field(52);
                            lfrfFieldRef3 := prrfHeader.Field(53);
                            //<ENRE1.00>
                            if not (
                              //</ENRE1.00>
                              ((Format(lfrfFieldRef2.Value) = '2') and (Format(lfrfFieldRef3.Value) <> ''))) then begin
                                exit;
                            end;
                        end;
                    end;//<ENRE1.00>
                    lfrfLineDocNo := lrrfLine.Field(3);
                    lfrfLineDocNo.SetFilter(Format(lfrfHdrDocNo.Value));
                end;
            else begin
                    Error('');
                end;
        end;
        gblnSalesBasedRebateMode := true;
        if lrrfLine.Find('-') then
            repeat
                CalcRebate(lrrfLine, pblnPeriodicCalc, lrecTempRebateEntry);
            until lrrfLine.Next = 0;
        Clear(gblnSalesBasedRebateMode);
        //</ENRE1.00>
    end;


    procedure DeleteSalesBasedRebateEntry(prrfLine: RecordRef)
    var
        lRecPurchRebateEntry: Record "Rebate Entry ELA";
        lintTableNo: Integer;
        lintLineNo: Integer;
        lfrfFieldRef: FieldRef;
    begin
        //<ENRE1.00>
        lintTableNo := prrfLine.Number;
        case lintTableNo of
            DATABASE::"Sales Line":
                begin
                    lfrfFieldRef := prrfLine.Field(1);
                    lRecPurchRebateEntry.SetFilter("Source Type", Format(lfrfFieldRef.Value));
                end;
        end;
        lfrfFieldRef := prrfLine.Field(3);
        lRecPurchRebateEntry.SetRange("Source No.", Format(lfrfFieldRef.Value));
        lfrfFieldRef := prrfLine.Field(4);
        Evaluate(lintLineNo, Format(lfrfFieldRef.Value));
        lRecPurchRebateEntry.SetRange("Source Line No.", lintLineNo);
        lRecPurchRebateEntry.SetRange("Rebate Code");
        lRecPurchRebateEntry.SetRange("Rebate Type", lRecPurchRebateEntry."Rebate Type"::"Sales-Based");
        lRecPurchRebateEntry.DeleteAll;
        //</ENRE1.00>
    end;


    procedure DeleteSBRebateEntryLines(prrfHeader: RecordRef)
    var
        lRecPurchRebateEntry: Record "Rebate Entry ELA";
        lintTableNo: Integer;
        lfrfFieldRef: FieldRef;
        lrecSalesProfitModifier: Record "Sales Profit Modifier ELA";
    begin
        //<ENRE1.00>
        lintTableNo := prrfHeader.Number;
        case lintTableNo of
            DATABASE::"Sales Header":
                begin
                    lfrfFieldRef := prrfHeader.Field(1);
                    lRecPurchRebateEntry.SetFilter("Source Type", Format(lfrfFieldRef.Value));

                    //<ENRE1.00>
                    lrecSalesProfitModifier.SetFilter("Document Type", Format(lfrfFieldRef.Value));
                    //<ENRE1.00>
                end;
        end;
        lfrfFieldRef := prrfHeader.Field(3);
        lRecPurchRebateEntry.SetRange("Source No.", Format(lfrfFieldRef.Value));
        lRecPurchRebateEntry.SetRange("Source Line No.");
        lRecPurchRebateEntry.SetRange("Rebate Code");
        lRecPurchRebateEntry.SetRange("Rebate Type", lRecPurchRebateEntry."Rebate Type"::"Sales-Based");
        lRecPurchRebateEntry.DeleteAll;
        //</ENRE1.00>

        //<ENRE1.00>
        lrecSalesProfitModifier.SetRange("Document No.", Format(lfrfFieldRef.Value));
        lrecSalesProfitModifier.DeleteAll;
        //</ENRE1.00>
    end;


    procedure SetSalesBasedRebateMode(pblnSalesBasedRebateMode: Boolean)
    begin
        //<ENRE1.00>
        gblnSalesBasedRebateMode := pblnSalesBasedRebateMode;
        //</ENRE1.00>
    end;

    local procedure CalcLastReceivedUnitCost(pcodVendor: Code[20]; pcodItem: Code[20]; pcodVariant: Code[10]; pdatBasis: Date; var pblnEntriesExist: Boolean) pdecResult: Decimal
    var
        lrecItemLedgerEntry: Record "Item Ledger Entry";
        lrecValueEntry: Record "Value Entry";
    begin
        //<ENRE1.00>

        lrecItemLedgerEntry.SetCurrentKey("Source Type", "Source No.", "Item No.",
                                           "Variant Code", "Posting Date");

        lrecItemLedgerEntry.SetRange("Source Type", lrecItemLedgerEntry."Source Type"::Vendor);
        lrecItemLedgerEntry.SetRange("Source No.", pcodVendor);
        lrecItemLedgerEntry.SetRange("Item No.", pcodItem);
        lrecItemLedgerEntry.SetFilter("Variant Code", '=%1', pcodVariant);
        lrecItemLedgerEntry.SetFilter("Posting Date", '..%1', pdatBasis);
        lrecItemLedgerEntry.SetRange("Document Type", lrecItemLedgerEntry."Document Type"::"Purchase Receipt");

        // try to find the exact variant match first...

        if (
          (not lrecItemLedgerEntry.FindLast)
        ) then begin
            if (
              (pcodVariant = '')
            ) then begin
                exit(0);
            end else begin
                // ...otherwise try a BLANK variant
                lrecItemLedgerEntry.SetFilter("Variant Code", '=%1', '');
                if (
                  (not lrecItemLedgerEntry.FindLast)
                ) then begin
                    exit(0);
                end;
            end;
        end;

        if (
          (lrecItemLedgerEntry.Quantity = 0)
        ) then begin
            exit(0);
        end;

        //<ENRE1.00>
        pblnEntriesExist := true;
        //</ENRE1.00>

        lrecValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");

        lrecValueEntry.SetRange("Item Ledger Entry No.", lrecItemLedgerEntry."Entry No.");
        lrecValueEntry.SetFilter("Item Charge No.", '=%1', '');

        pdecResult := 0;

        if (
          (lrecValueEntry.FindSet(false))
        ) then begin
            repeat
                pdecResult := pdecResult + lrecValueEntry."Purchase Amount (Actual)" + lrecValueEntry."Purchase Amount (Expected)";
            until lrecValueEntry.Next = 0;
        end;

        // total cost / quantity = cost per

        pdecResult := pdecResult / lrecItemLedgerEntry.Quantity;

        grecGLSetup.Get;

        pdecResult := Round(pdecResult, grecGLSetup."Unit-Amount Rounding Precision");

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
                        lrecRebateJnlLine."Applies-To Vendor No." := precRLE."Post-to Vendor No.";

                        case precRLE."Source Type" of
                            precRLE."Source Type"::"Posted Invoice":
                                begin
                                    lrecRebateJnlLine."Applies-To Source Type" := lrecRebateJnlLine."Applies-To Source Type"::"Posted Purch. Invoice";
                                end;
                            precRLE."Source Type"::"Posted Cr. Memo":
                                begin
                                    lrecRebateJnlLine."Applies-To Source Type" := lrecRebateJnlLine."Applies-To Source Type"::"Posted Purch. Cr. Memo";
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
                end;
        end;

        //</ENRE1.00>
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUserDefinedCostBasisCalculation(var RecRef: RecordRef; var UnitCost: Decimal)
    begin
    end;
}

