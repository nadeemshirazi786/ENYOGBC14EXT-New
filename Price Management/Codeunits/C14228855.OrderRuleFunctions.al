/// <summary>
/// Codeunit EN Order Rule Functions (ID 14228855).
/// </summary>
codeunit 14228855 "EN Order Rule Functions"
{


    trigger OnRun()
    begin
    end;

    var
        grecTempOrderRuleSalesLine: Record "EN Order Rule Sales Line" temporary;
        
        gconError001: Label 'Item No. %1 is not setup to be sold in the Customer Order Rules setup.';
        gblnTemporaryBypass: Boolean;
        gblnFromOrderSheet: Boolean;
        gcodOrderSheetCustomer: Code[20];
        gcodOrderSheetShipTo: Code[10];
        gdteOrderSheetDate: Date;
        gconError002: Label 'Item No. %1 is not allowed to be sold in %2 to this customer.';
        gjfText030: Label 'Order Rule';
        gjfText031: Label 'CONFIRM';
        grecSalesSetup: Record "Sales & Receivables Setup";
        gconError003: Label 'Item No. %1 is not set up to be sold to customer %2.';
        gconError004: Label 'Item No. %1 is not allowed to be sold in %2 to customer %3.';

    
    procedure cbCheckLine(precSalesLine: Record "Sales Line"; pblnWithUOMFilter: Boolean)
    var
        lrecOrderRuleDetail: Record "EN Order Rule Detail";
        lrecSalesHeader: Record "Sales Header";
        lrecOrderRuleDetailLine: Record "EN Order Rule Detail Line";
        lrecCustomer: Record "Customer";
        lblnFoundOne: Boolean;
        lrecShipTo: Record "Ship-to Address";
    begin
        IF NOT gblnFromOrderSheet THEN BEGIN
            lrecSalesHeader.GET(precSalesLine."Document Type", precSalesLine."Document No.")
        END ELSE BEGIN
            lrecSalesHeader."Document Type" := precSalesLine."Document Type";
            lrecSalesHeader."No." := precSalesLine."Document No.";
            lrecSalesHeader."Sell-to Customer No." := gcodOrderSheetCustomer;
            lrecSalesHeader."Ship-to Code" := gcodOrderSheetShipTo;
            lrecSalesHeader."Posting Date" := gdteOrderSheetDate;

            lrecCustomer.GET(gcodOrderSheetCustomer);
            lrecSalesHeader."Order Rule Group ELA" := lrecCustomer."Order Rule Group ELA";
            IF lrecShipTo.GET(lrecSalesHeader."Sell-to Customer No.", lrecSalesHeader."Ship-to Code") THEN
                IF lrecShipTo."Order Rule Group" <> '' THEN
                    lrecSalesHeader."Order Rule Group ELA" := lrecShipTo."Order Rule Group";

        END;

        IF lrecSalesHeader."Posting Date" = 0D THEN
            lrecSalesHeader."Posting Date" := WORKDATE;

        IF NOT cbCheckUseOrderRule(lrecSalesHeader."Document Type", lrecSalesHeader."No.") AND NOT gblnTemporaryBypass THEN BEGIN
            EXIT;
        END;

        cbCreateTempRecord(precSalesLine);

        grecTempOrderRuleSalesLine.GET(precSalesLine."Document Type", precSalesLine."Document No.", precSalesLine."Line No.");

        lblnFoundOne := FALSE;

        //-- First do Sales Type of Customer
        lrecOrderRuleDetail.SETRANGE("Sales Code", lrecSalesHeader."Sell-to Customer No.");
        lrecOrderRuleDetail.SETFILTER("Ship-To Address Code", '%1|%2', '', lrecSalesHeader."Ship-to Code");
        lrecOrderRuleDetail.SETRANGE("Item Type", lrecOrderRuleDetail."Item Type"::"Item No.");
        lrecOrderRuleDetail.SETRANGE("Item Ref. No.", precSalesLine."No.");
        //lrecOrderRuleDetail.SETFILTER("Start Date",'%1|<=%2',0D,lrecSalesHeader."Posting Date"); //<IB55639EP> - commented out.
        lrecOrderRuleDetail.SETFILTER("Unit of Measure Code", '%1|%2', '', precSalesLine."Unit of Measure Code");
        //lrecOrderRuleDetail.SETFILTER("End Date",'%1|>=%2',0D,lrecSalesHeader."Shipment Date"); //<IB55639EP> - commented out.

        IF lrecOrderRuleDetail.FINDLAST THEN BEGIN
            lblnFoundOne := TRUE;
        END;

        //-- Second do Order Rule Group if appropriate
        IF (NOT lblnFoundOne) AND (lrecSalesHeader."Order Rule Group ELA" <> '') THEN BEGIN
            lrecOrderRuleDetail.SETRANGE("Sales Code", lrecSalesHeader."Order Rule Group ELA");
            IF lrecOrderRuleDetail.FINDLAST THEN BEGIN
                lblnFoundOne := TRUE;
            END;
        END;

        //-- Third do all customers (just not releasing filter but applying blank ("all customers" will have a blank Sales Code)
        IF NOT lblnFoundOne THEN BEGIN
            lrecOrderRuleDetail.SETFILTER("Sales Code", '%1', '');
            IF lrecOrderRuleDetail.FINDLAST THEN BEGIN
                lblnFoundOne := TRUE;
            END;
        END;

        //Item - Assumption is that the most specific record is the one to use - ignore the others
        IF lblnFoundOne THEN BEGIN

            
            IF NOT (((lrecOrderRuleDetail."Start Date" = 0D) OR (lrecSalesHeader."Posting Date" >= lrecOrderRuleDetail."Start Date")) AND ((lrecOrderRuleDetail."End Date" = 0D) OR (lrecSalesHeader."Shipment Date" <= lrecOrderRuleDetail."End Date")))
            THEN BEGIN
                grecTempOrderRuleSalesLine."Item Not Allowed" := TRUE;
            END;
            

            grecTempOrderRuleSalesLine."Item Not Setup" := FALSE;

            
            IF grecTempOrderRuleSalesLine."Item Not Allowed" = FALSE THEN
                
                IF lrecOrderRuleDetail.Status = lrecOrderRuleDetail.Status::"Not Allowed" THEN
                    grecTempOrderRuleSalesLine."Item Not Allowed" := TRUE
                ELSE
                    grecTempOrderRuleSalesLine."Item Not Allowed" := FALSE;

            grecTempOrderRuleSalesLine."Expected Min. Qty." := lrecOrderRuleDetail."Min. Order Qty.";
            grecTempOrderRuleSalesLine."Expected Order Multiple" := lrecOrderRuleDetail."Order Multiple";

            IF (precSalesLine.Quantity >= lrecOrderRuleDetail."Min. Order Qty.") OR (precSalesLine.Quantity < 0) THEN BEGIN
                grecTempOrderRuleSalesLine."Item Min. Qty." := FALSE;
            END;

            IF lrecOrderRuleDetail."Order Multiple" <> 0 THEN BEGIN
                IF precSalesLine.Quantity MOD lrecOrderRuleDetail."Order Multiple" = 0 THEN BEGIN
                    grecTempOrderRuleSalesLine."Item Order Multiple" := FALSE;
                END;
            END ELSE BEGIN
                grecTempOrderRuleSalesLine."Item Order Multiple" := FALSE;
            END;
        END;

        //Item Category - If Item not found look for Item Category - most specific one only
        IF NOT cbLinePasses(grecTempOrderRuleSalesLine) THEN BEGIN
            //Look for Item Category records
            lblnFoundOne := FALSE;
            lrecOrderRuleDetail.SETRANGE("Sales Code", lrecSalesHeader."Sell-to Customer No.");
            lrecOrderRuleDetail.SETRANGE("Item Type", lrecOrderRuleDetail."Item Type"::"Item Category");
            lrecOrderRuleDetail.SETRANGE("Item Ref. No.", precSalesLine."Item Category Code");
            IF lrecOrderRuleDetail.FINDLAST THEN BEGIN
                lblnFoundOne := TRUE;
            END;

            //-- Second by "Order Rule Group"
            IF (NOT lblnFoundOne) AND (lrecSalesHeader."Order Rule Group ELA" <> '') THEN BEGIN
                lrecOrderRuleDetail.SETRANGE("Sales Code", lrecSalesHeader."Order Rule Group ELA");
                IF lrecOrderRuleDetail.FINDLAST THEN BEGIN
                    lblnFoundOne := TRUE;
                END;
            END;

            //-- Third By "All Customers" so Sales Code will be blank
            IF NOT lblnFoundOne THEN BEGIN
                lrecOrderRuleDetail.SETFILTER("Sales Code", '%1', '');
                IF lrecOrderRuleDetail.FINDLAST THEN BEGIN
                    lblnFoundOne := TRUE;
                END;
            END;

            IF lblnFoundOne THEN BEGIN

                IF NOT (((lrecOrderRuleDetail."Start Date" = 0D) OR (lrecSalesHeader."Posting Date" >= lrecOrderRuleDetail."Start Date")) AND ((lrecOrderRuleDetail."End Date" = 0D) OR (lrecSalesHeader."Shipment Date" <= lrecOrderRuleDetail."End Date")))
                THEN BEGIN
                    grecTempOrderRuleSalesLine."Category Not Allowed" := TRUE;
                END;

                grecTempOrderRuleSalesLine."Item Category Not Setup" := FALSE;

                IF grecTempOrderRuleSalesLine."Category Not Allowed" = FALSE THEN
                    IF lrecOrderRuleDetail.Status = lrecOrderRuleDetail.Status::"Not Allowed" THEN
                        grecTempOrderRuleSalesLine."Category Not Allowed" := TRUE
                    ELSE
                        grecTempOrderRuleSalesLine."Category Not Allowed" := FALSE;

                IF grecTempOrderRuleSalesLine."Item Not Setup" THEN BEGIN
                    grecTempOrderRuleSalesLine."Expected Min. Qty." := lrecOrderRuleDetail."Min. Order Qty.";
                    grecTempOrderRuleSalesLine."Expected Order Multiple" := lrecOrderRuleDetail."Order Multiple";
                END;
                IF precSalesLine.Quantity >= lrecOrderRuleDetail."Min. Order Qty." THEN BEGIN
                    grecTempOrderRuleSalesLine."Item Category Min. Qty." := FALSE;
                END;
                IF lrecOrderRuleDetail."Order Multiple" <> 0 THEN BEGIN
                    IF precSalesLine.Quantity MOD lrecOrderRuleDetail."Order Multiple" = 0 THEN BEGIN
                        grecTempOrderRuleSalesLine."Item Category Order Multiple" := FALSE;
                    END;
                END ELSE BEGIN
                    grecTempOrderRuleSalesLine."Item Category Order Multiple" := FALSE;
                END;
            END;
        END;

        //Check For Combinations - to see if Item can potentially be sold as part of combination
        IF NOT yogComboLinePasses(grecTempOrderRuleSalesLine) THEN BEGIN
            lrecOrderRuleDetail.SETFILTER("Sales Code", '%1|%2|%3', lrecSalesHeader."Sell-to Customer No.", lrecSalesHeader."Order Rule Group ELA", '');
            lrecOrderRuleDetail.SETRANGE("Item Type", lrecOrderRuleDetail."Item Type"::Combination);
            lrecOrderRuleDetail.SETRANGE("Item Ref. No.");

            IF lrecOrderRuleDetail.FINDSET THEN
                REPEAT
                    IF (((lrecOrderRuleDetail."Start Date" = 0D) OR (lrecSalesHeader."Posting Date" >= lrecOrderRuleDetail."Start Date")) AND ((lrecOrderRuleDetail."End Date" = 0D) OR (lrecSalesHeader."Shipment Date" <= lrecOrderRuleDetail."End Date")))
                    THEN BEGIN
                        lrecOrderRuleDetailLine.SETRANGE("Sales Type", lrecOrderRuleDetail."Sales Type");
                        lrecOrderRuleDetailLine.SETRANGE("Sales Code", lrecOrderRuleDetail."Sales Code");
                        lrecOrderRuleDetailLine.SETRANGE("Ship-To Address Code", lrecOrderRuleDetail."Ship-To Address Code");
                        lrecOrderRuleDetailLine.SETRANGE("Item Type", lrecOrderRuleDetail."Item Type");
                        lrecOrderRuleDetailLine.SETRANGE("Item Ref. No.", lrecOrderRuleDetail."Item Ref. No.");
                        lrecOrderRuleDetailLine.SETRANGE("Start Date", lrecOrderRuleDetail."Start Date");
                        lrecOrderRuleDetailLine.SETRANGE("Unit of Measure Code", lrecOrderRuleDetail."Unit of Measure Code");
                        lrecOrderRuleDetailLine.SETRANGE("Item No.", precSalesLine."No.");
                        IF NOT lrecOrderRuleDetailLine.ISEMPTY THEN BEGIN
                            grecTempOrderRuleSalesLine."Combination Not Setup" := FALSE;
                        END;
                    END;
                UNTIL lrecOrderRuleDetail.NEXT = 0;
        END;

        grecTempOrderRuleSalesLine.MODIFY;
    end;

    
    procedure cbCheckOrder(precSalesHeader: Record "Sales Header"): Boolean
    var
        lrecSalesLine: Record "Sales Line";
        lrecTempOrderRuleSalesLine: Record "EN Order Rule Sales Line";
        lrecCustomer: Record "Customer";
    begin
        IF NOT cbCheckUseOrderRule(precSalesHeader."Document Type", precSalesHeader."No.") AND NOT gblnTemporaryBypass THEN BEGIN
            EXIT(TRUE);
        END;

        //Delete Temporary Recordset
        cbClearTempRecordset;

        //Check Lines
        lrecSalesLine.SETRANGE("Document Type", precSalesHeader."Document Type");
        lrecSalesLine.SETRANGE("Document No.", precSalesHeader."No.");
        lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::Item);
        IF lrecSalesLine.FINDSET THEN BEGIN
            REPEAT
                IF lrecSalesLine."No." <> '' THEN
                    cbCheckLine(lrecSalesLine, TRUE);
            UNTIL lrecSalesLine.NEXT = 0;
        END;

        //Check All Lines together
        cbCheckCombinations(precSalesHeader);

        //Update Unit Price
        //<<EN1.00
        //jfcbUpdateUnitPrice;
        IF NOT lrecSalesLine."Lock Pricing ELA" THEN
            cbUpdateUnitPrice;
        //>>EN1.00

        // revert prices for combinations that are no longer valid
        lrecSalesLine.RESET;
        lrecSalesLine.SETRANGE("Document Type", precSalesHeader."Document Type");
        lrecSalesLine.SETRANGE("Document No.", precSalesHeader."No.");
        lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::Item);

        IF lrecSalesLine.FINDSET(TRUE) THEN BEGIN
            REPEAT
                IF (lrecSalesLine."No." <> '') AND (lrecSalesLine."Sales Price Source ELA" = gjfText031) ///AND (lrecSalesLine."Unit Price Approved By" = '') 
                THEN BEGIN
                    lrecSalesLine."Sales Price Source ELA" := '';
                    lrecSalesLine.VALIDATE("Unit of Measure Code");
                    lrecSalesLine.MODIFY(TRUE);
                END;
            UNTIL lrecSalesLine.NEXT = 0;
        END;
        //</JF10010AC>

        //Delete Lines that Pass - only show problem lines
        cbDeletePasses;

        IF gblnTemporaryBypass THEN
            EXIT(TRUE);

        //-- If using exceptions only, remove the 'not setup' rule details
        IF grecTempOrderRuleSalesLine.FINDSET THEN BEGIN
            IF lrecCustomer.GET(precSalesHeader."Sell-to Customer No.") THEN BEGIN
                REPEAT
                    CASE lrecCustomer."Order Rule Usage ELA" OF
                        lrecCustomer."Order Rule Usage ELA"::"Exceptions Only":
                            BEGIN
                                IF (grecTempOrderRuleSalesLine."Item Not Setup") AND
                                   (grecTempOrderRuleSalesLine."Item Category Not Setup") AND
                                   (grecTempOrderRuleSalesLine."Combination Not Setup") THEN
                                    grecTempOrderRuleSalesLine.DELETE;
                            END;
                    END;
                UNTIL grecTempOrderRuleSalesLine.NEXT = 0;
            END;
        END;

        IF grecTempOrderRuleSalesLine.FINDSET THEN BEGIN
            IF GUIALLOWED THEN
                PAGE.RUN(14228861, grecTempOrderRuleSalesLine);
            EXIT(FALSE);
        END ELSE BEGIN
            EXIT(TRUE)
        END;
    end;

    
    procedure cbCheckCombinations(precSalesHeader: Record "Sales Header")
    var
        lrecSalesLine: Record "Sales Line";
        lrecOrderRuleDetail: Record "EN Order Rule Detail";
        lrecSalesLine2: Record "Sales Line";
        lrecOrderRuleDetailLine: Record "EN Order Rule Detail Line";
        ldecQuantity: Decimal;
        lint: Integer;
        lblnDoOrderRuleGroup: Boolean;
    begin
        //<JF10010AC>
        // mark pre-existing combination pricing as Sales Price Source := 'CONFIRM'
        lrecSalesLine.RESET;
        lrecSalesLine.SETRANGE("Document Type", precSalesHeader."Document Type");
        lrecSalesLine.SETRANGE("Document No.", precSalesHeader."No.");
        lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::Item);
        lrecSalesLine.SETFILTER("No.", '<>%1', '');
        lrecSalesLine.SETFILTER("Sales Price Source ELA", '=%1', gjfText030); // 'Order Rule'
        ///lrecSalesLine.SETFILTER("Unit Price Approved By", '=%1', '');
        //<DP20160524>
        lrecSalesLine.SETFILTER("Quantity Shipped", '=%1', 0);
        //</DP20160524>
        lrecSalesLine.MODIFYALL("Sales Price Source ELA", gjfText031); // 'CONFIRM'

        lrecSalesLine.RESET;
        //</JF10010AC>

        //<JF11133AC>
        grecSalesSetup.GET;
        //</JF11133AC>

        lrecSalesLine.SETRANGE("Document Type", precSalesHeader."Document Type");
        lrecSalesLine.SETRANGE("Document No.", precSalesHeader."No.");
        lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::Item);
        lrecSalesLine.SETFILTER("No.", '<>%1', '');
        IF lrecSalesLine.FINDSET THEN
            REPEAT
                grecTempOrderRuleSalesLine.GET(lrecSalesLine."Document Type", lrecSalesLine."Document No.", lrecSalesLine."Line No.");
                FOR lint := 1 TO 3 DO IF NOT yogComboLinePasses(grecTempOrderRuleSalesLine) THEN BEGIN
                        // three passes to apply "Order Rule Grp Cust. Priority" to Sales Type property
                        lrecOrderRuleDetail.SETCURRENTKEY(
                          "Sales Type", "Sales Code", "Ship-To Address Code", "Item Type",
                          "Unit of Measure Code", "Min. Order Qty.");
                        lrecOrderRuleDetail.ASCENDING(FALSE);

                        CASE lint OF
                            1:
                                BEGIN
                                    IF grecSalesSetup."Order Rule Grp Cust. Prio. ELA"
                                    = grecSalesSetup."Order Rule Grp Cust. Prio. ELA"::"Use Order Rule Group"
                                    THEN BEGIN
                                        lblnDoOrderRuleGroup := TRUE;
                                    END;
                                END;
                            2:
                                BEGIN
                                    lblnDoOrderRuleGroup := NOT lblnDoOrderRuleGroup;
                                END;
                            3:
                                BEGIN
                                    // "All Customers" always has a lower priority than a specific match
                                    lrecOrderRuleDetail.SETRANGE("Sales Type", lrecOrderRuleDetail."Sales Type"::"All Customers");
                                    lrecOrderRuleDetail.SETRANGE("Sales Code");
                                END;
                        END;

                        IF (lint < 3)
                        THEN BEGIN
                            IF lblnDoOrderRuleGroup
                            THEN BEGIN
                                lrecOrderRuleDetail.SETRANGE("Sales Type", lrecOrderRuleDetail."Sales Type"::"Order Rule Group");
                                lrecOrderRuleDetail.SETRANGE("Sales Code", precSalesHeader."Order Rule Group ELA");
                            END ELSE BEGIN
                                lrecOrderRuleDetail.SETRANGE("Sales Type", lrecOrderRuleDetail."Sales Type"::Customer);
                                lrecOrderRuleDetail.SETRANGE("Sales Code", precSalesHeader."Sell-to Customer No.");
                            END;
                        END;

                        lrecOrderRuleDetail.SETFILTER("Ship-To Address Code", '%1|%2', precSalesHeader."Ship-to Code", '');
                        lrecOrderRuleDetail.SETRANGE("Item Type", lrecOrderRuleDetail."Item Type"::Combination);
                        lrecOrderRuleDetail.SETFILTER("Start Date", '%1|<=%2', 0D, precSalesHeader."Posting Date");
                        lrecOrderRuleDetail.SETRANGE("Unit of Measure Code", lrecSalesLine."Unit of Measure Code");
                        lrecOrderRuleDetail.SETFILTER("End Date", '%1|>=%2', 0D, precSalesHeader."Shipment Date"); //<IB55639EP> - Changed to use Shipment Date instead of Posting Date to align with other functionality.

                        IF lrecOrderRuleDetail.FIND('-') THEN
                            REPEAT
                                ldecQuantity := 0;
                                lrecOrderRuleDetailLine.SETRANGE("Sales Type", lrecOrderRuleDetail."Sales Type");
                                lrecOrderRuleDetailLine.SETRANGE("Sales Code", lrecOrderRuleDetail."Sales Code");
                                lrecOrderRuleDetailLine.SETRANGE("Ship-To Address Code", lrecOrderRuleDetail."Ship-To Address Code");
                                lrecOrderRuleDetailLine.SETRANGE("Item Type", lrecOrderRuleDetail."Item Type");
                                lrecOrderRuleDetailLine.SETRANGE("Item Ref. No.", lrecOrderRuleDetail."Item Ref. No.");
                                lrecOrderRuleDetailLine.SETRANGE("Start Date", lrecOrderRuleDetail."Start Date");
                                lrecOrderRuleDetailLine.SETRANGE("Unit of Measure Code", lrecOrderRuleDetail."Unit of Measure Code");

                                lrecSalesLine2.SETRANGE("Document Type", lrecSalesLine."Document Type");
                                lrecSalesLine2.SETRANGE("Document No.", lrecSalesLine."Document No.");
                                lrecSalesLine2.SETRANGE(Type, lrecSalesLine.Type::Item);
                                lrecSalesLine2.SETRANGE("Unit of Measure Code", lrecOrderRuleDetail."Unit of Measure Code");

                                IF lrecOrderRuleDetailLine.FIND('-') THEN
                                    REPEAT
                                        //Add up qty. on all lines for each combination setup
                                        lrecSalesLine2.SETRANGE("No.", lrecOrderRuleDetailLine."Item No.");
                                        IF lrecSalesLine2.FIND('-') THEN
                                            REPEAT
                                                ldecQuantity := ldecQuantity + lrecSalesLine2.Quantity;
                                                grecTempOrderRuleSalesLine.GET(lrecSalesLine2."Document Type", lrecSalesLine2."Document No.", lrecSalesLine2."Line No.");
                                                grecTempOrderRuleSalesLine."Combination Not Setup" := FALSE;
                                                grecTempOrderRuleSalesLine."Expected Combination Min. Qty." := lrecOrderRuleDetail."Min. Order Qty.";
                                                grecTempOrderRuleSalesLine.MODIFY;
                                            UNTIL lrecSalesLine2.NEXT = 0
UNTIL lrecOrderRuleDetailLine.NEXT = 0;

                                IF ldecQuantity >= lrecOrderRuleDetail."Min. Order Qty." THEN BEGIN
                                    //Go through the Items in the combination again and mark them all as meeting min. qty.
                                    IF lrecOrderRuleDetailLine.FIND('-') THEN
                                        REPEAT
                                            lrecSalesLine2.SETRANGE("No.", lrecOrderRuleDetailLine."Item No.");
                                            IF lrecSalesLine2.FIND('-') THEN
                                                REPEAT
                                                    grecTempOrderRuleSalesLine.GET(lrecSalesLine2."Document Type", lrecSalesLine2."Document No.", lrecSalesLine2."Line No.");
                                                    grecTempOrderRuleSalesLine."Combination Min. Qty." := FALSE;
                                                    grecTempOrderRuleSalesLine."Combination Unit Price" := lrecOrderRuleDetailLine."Unit Price";
                                                    grecTempOrderRuleSalesLine."Combination Delivered Price" := lrecOrderRuleDetailLine."Delivered Price";
                                                    grecTempOrderRuleSalesLine."Sales Allowance Amount" := lrecOrderRuleDetailLine."Sales Allowance Amount";
                                                    grecTempOrderRuleSalesLine.MODIFY;
                                                UNTIL lrecSalesLine2.NEXT = 0;
                                        UNTIL lrecOrderRuleDetailLine.NEXT = 0;
                                END;

                                grecTempOrderRuleSalesLine.GET(lrecSalesLine."Document Type", lrecSalesLine."Document No.", lrecSalesLine."Line No.");
                                //<IB55639EP>
                            UNTIL (lrecOrderRuleDetail.NEXT = 0) OR yogComboLinePasses(grecTempOrderRuleSalesLine);
                        //</IB55639EP>
                        //UNTIL (lrecOrderRuleDetail.NEXT = 0) OR jfcbLinePasses(grecTempOrderRuleSalesLine); //<IB55639EP> - commented out
                    END;
            UNTIL lrecSalesLine.NEXT = 0;
    end;

    
    procedure cbCreateTempRecord(precSalesLine: Record "Sales Line")
    begin
        grecTempOrderRuleSalesLine.INIT;
        grecTempOrderRuleSalesLine."Document Type" := precSalesLine."Document Type";
        grecTempOrderRuleSalesLine."Document No." := precSalesLine."Document No.";
        grecTempOrderRuleSalesLine."Line No." := precSalesLine."Line No.";
        grecTempOrderRuleSalesLine."Item No." := precSalesLine."No.";
        grecTempOrderRuleSalesLine."Item Not Setup" := TRUE;
        grecTempOrderRuleSalesLine."Item Min. Qty." := TRUE;
        grecTempOrderRuleSalesLine."Item Order Multiple" := TRUE;
        grecTempOrderRuleSalesLine."Item Category Not Setup" := TRUE;
        grecTempOrderRuleSalesLine."Item Category Min. Qty." := TRUE;
        grecTempOrderRuleSalesLine."Item Category Order Multiple" := TRUE;
        grecTempOrderRuleSalesLine."Combination Not Setup" := TRUE;
        grecTempOrderRuleSalesLine."Combination Min. Qty." := TRUE;

        //<JF00025MG>
        grecTempOrderRuleSalesLine."Item Not Allowed" := FALSE;
        grecTempOrderRuleSalesLine."Category Not Allowed" := FALSE;
        //</JF00025MG>

        grecTempOrderRuleSalesLine.INSERT;
    end;

    
    procedure cbCheckUseOrderRule(pintDocumentType: Integer; pcodDocumentNo: Code[20]): Boolean
    var
        lrecCustomer: Record "Customer";
        lrecSalesHeader: Record "Sales Header";
        lrecSRSetup: Record "Sales & Receivables Setup";
    begin
        IF NOT gblnFromOrderSheet THEN BEGIN
            lrecSalesHeader.GET(pintDocumentType, pcodDocumentNo);
            IF NOT (lrecSalesHeader."Document Type" IN
              [lrecSalesHeader."Document Type"::Order,
               //<DP20150908>
               lrecSalesHeader."Document Type"::Quote,
               //</DP20150908>
               lrecSalesHeader."Document Type"::Invoice])
            THEN
                EXIT;
            lrecCustomer.GET(lrecSalesHeader."Sell-to Customer No.");
        END ELSE BEGIN
            lrecCustomer.GET(gcodOrderSheetCustomer);

            IF lrecCustomer."Order Rule Usage ELA" = lrecCustomer."Order Rule Usage ELA"::None THEN
                lrecSalesHeader."Bypass Order Rules ELA" := TRUE;
        END;

        lrecSRSetup.GET;

        IF (lrecSalesHeader."Bypass Order Rules ELA") OR (lrecCustomer."Order Rule Usage ELA" = lrecCustomer."Order Rule Usage ELA"::None) THEN
            gblnTemporaryBypass := TRUE;

        IF (lrecSalesHeader."Bypass Order Rules ELA") OR NOT lrecSRSetup."Use Order Rules ELA" THEN BEGIN
            EXIT(FALSE);
        END ELSE BEGIN
            EXIT(TRUE);
        END;
    end;

    
    procedure cbLinePasses(precTempOrderRuleSalesLine: Record "EN Order Rule Sales Line" temporary): Boolean
    var
        lrecSRSetup: Record "Sales & Receivables Setup";
    begin
        //This function used to figure out whether the line has enough flags turned off in order to warrant an
        //Order Rule pass
        lrecSRSetup.GET;

        IF (grecTempOrderRuleSalesLine."Item Not Allowed") OR
           (grecTempOrderRuleSalesLine."Category Not Allowed") THEN
            EXIT(FALSE);

        //Item Level All Passes
        IF (precTempOrderRuleSalesLine."Item Not Setup" = FALSE) AND
           (precTempOrderRuleSalesLine."Item Min. Qty." = FALSE) AND
           (precTempOrderRuleSalesLine."Item Order Multiple" = FALSE) THEN BEGIN
            EXIT(TRUE);
        END;

        IF lrecSRSetup."Item Setup Priority ELA" = lrecSRSetup."Item Setup Priority ELA"::"Item Setup Takes Priority" THEN BEGIN
            //Item Level is not setup and Item Category All Passes
            IF (precTempOrderRuleSalesLine."Item Not Setup" = TRUE) AND
               (precTempOrderRuleSalesLine."Item Category Not Setup" = FALSE) AND
               (precTempOrderRuleSalesLine."Item Category Min. Qty." = FALSE) AND
               (precTempOrderRuleSalesLine."Item Category Order Multiple" = FALSE) THEN BEGIN
                EXIT(TRUE);
            END;
        END ELSE BEGIN
            //Item Category All Passes
            IF (precTempOrderRuleSalesLine."Item Category Not Setup" = FALSE) AND
               (precTempOrderRuleSalesLine."Item Category Min. Qty." = FALSE) AND
               (precTempOrderRuleSalesLine."Item Category Order Multiple" = FALSE) THEN BEGIN
                EXIT(TRUE);
            END;
        END;

        //Meets Combination Min. Qty. - Does not have to meet the order multiple
        IF (precTempOrderRuleSalesLine."Combination Not Setup" = FALSE) AND
           (precTempOrderRuleSalesLine."Combination Min. Qty." = FALSE) THEN BEGIN
            EXIT(TRUE);
        END;
    end;

    
    procedure cbDeletePasses()
    begin
        IF grecTempOrderRuleSalesLine.FIND('-') THEN
            REPEAT
                IF cbLinePasses(grecTempOrderRuleSalesLine) THEN BEGIN
                    grecTempOrderRuleSalesLine.DELETE;
                END;
            UNTIL grecTempOrderRuleSalesLine.NEXT = 0;
    end;

    
    procedure cbClearTempRecordset()
    begin
        grecTempOrderRuleSalesLine.DELETEALL;
    end;

    
    procedure cbSalesLineItemOK(precSalesLine: Record "Sales Line")
    var
        lrecSRSetup: Record "Sales & Receivables Setup";
        lrecCustomer: Record "Customer";
    begin
        IF NOT cbCheckUseOrderRule(precSalesLine."Document Type", precSalesLine."Document No.") THEN
            EXIT;

        lrecSRSetup.GET;
        IF lrecSRSetup."Validate Item No. On Entry ELA" THEN BEGIN
            cbCheckLine(precSalesLine, FALSE);
            grecTempOrderRuleSalesLine.GET(precSalesLine."Document Type", precSalesLine."Document No.", precSalesLine."Line No.");

            //-- We only want to enforce that an order rule exists if the ORder Rule Usage is Strictly Enforced at the
            //--   customer level
            IF lrecCustomer.GET(precSalesLine."Sell-to Customer No.") THEN BEGIN
                CASE lrecCustomer."Order Rule Usage ELA" OF
                    lrecCustomer."Order Rule Usage ELA"::"Strictly Enforce":
                        BEGIN
                            IF (grecTempOrderRuleSalesLine."Item Not Setup") AND
                               (grecTempOrderRuleSalesLine."Item Category Not Setup")
                               THEN BEGIN //<IB55639EP> - Removed combination check condition AND (grecTempOrderRuleSalesLine."Combination Not Setup")
                                          //<DP20160211> - add Customer No. to error message.
                                ERROR(gconError003, precSalesLine."No.", precSalesLine."Sell-to Customer No.");
                            END;
                        END;
                END;
            END ELSE BEGIN
                ERROR(gconError003, precSalesLine."No.", precSalesLine."Sell-to Customer No.");
            END;

            //-- check to see if the item is not allowed for this customer
            IF (grecTempOrderRuleSalesLine."Item Not Allowed") OR
               (grecTempOrderRuleSalesLine."Category Not Allowed") THEN
                ERROR(gconError004, precSalesLine."No.", precSalesLine."Unit of Measure Code", precSalesLine."Sell-to Customer No.");
        END;
    end;

    
    procedure cbSalesLineDefaultMinQty(precSalesLine: Record "Sales Line"): Decimal
    var
        lrecSRSetup: Record "Sales & Receivables Setup";
    begin
        IF NOT cbCheckUseOrderRule(precSalesLine."Document Type", precSalesLine."Document No.") THEN
            EXIT;

        lrecSRSetup.GET;
        IF lrecSRSetup."Default Min. Qty. On Entry ELA" THEN BEGIN
            cbCheckLine(precSalesLine, TRUE);
            grecTempOrderRuleSalesLine.GET(precSalesLine."Document Type", precSalesLine."Document No.", precSalesLine."Line No.");
            EXIT(grecTempOrderRuleSalesLine."Expected Min. Qty.");
        END;
    end;

    
    procedure cbSalesLineOrderMultiple(precSalesLine: Record "Sales Line"): Decimal
    var
        lrecSRSetup: Record "Sales & Receivables Setup";
        ldecQty: Decimal;
    begin
        IF NOT cbCheckUseOrderRule(precSalesLine."Document Type", precSalesLine."Document No.") THEN
            EXIT(precSalesLine.Quantity);

        lrecSRSetup.GET;
        ldecQty := precSalesLine.Quantity;
        IF lrecSRSetup."Auto Round Order Multiples ELA" THEN BEGIN
            cbCheckLine(precSalesLine, TRUE);
            grecTempOrderRuleSalesLine.GET(precSalesLine."Document Type", precSalesLine."Document No.", precSalesLine."Line No.");
            IF grecTempOrderRuleSalesLine."Expected Order Multiple" <> 0 THEN BEGIN
                ldecQty := ROUND(ldecQty, 1, '>');
                IF ldecQty MOD grecTempOrderRuleSalesLine."Expected Order Multiple" <> 0 THEN
                    REPEAT
                        ldecQty := ldecQty + 1;
                    UNTIL ldecQty MOD grecTempOrderRuleSalesLine."Expected Order Multiple" = 0;
            END;
        END;
        EXIT(ldecQty);
    end;

    
    procedure cbUpdateUnitPrice()
    var
        lrecSalesLine: Record "Sales Line";
        lrecSRSetup: Record "Sales & Receivables Setup";
        lcduCustItemSurchgMgt: Codeunit "EN Delivery Charge Mgt";
    begin
        //Update the Sales Lines based on Combination Unit Pricing
        lrecSRSetup.GET;
        grecTempOrderRuleSalesLine.SETFILTER(grecTempOrderRuleSalesLine."Combination Unit Price", '>0');
        IF grecTempOrderRuleSalesLine.FIND('-') THEN
            REPEAT

                //If the priority is to use combination pricing or the Item didn't satisfy on it's own then change to the combo price
                IF (lrecSRSetup."Order Rule Comb Price Prio ELA" = lrecSRSetup."Order Rule Comb Price Prio ELA"::"Use Combination Price") OR
                   ((grecTempOrderRuleSalesLine."Item Min. Qty." = FALSE) OR
                   (grecTempOrderRuleSalesLine."Item Category Min. Qty." = FALSE)) THEN BEGIN
                    lrecSalesLine.GET(grecTempOrderRuleSalesLine."Document Type", grecTempOrderRuleSalesLine."Document No.",
                                    grecTempOrderRuleSalesLine."Line No.");
                    IF NOT lrecSalesLine."Lock Pricing ELA" THEN  //EN1.00
                        //IF lrecSalesLine."Unit Price Approved By" = '' THEN BEGIN
                            lrecSalesLine.VALIDATE("Unit Price", grecTempOrderRuleSalesLine."Combination Unit Price");
                            lrecSalesLine."Sales Price Source ELA" := gjfText030; // 'Order Rule'
                            lrecSalesLine.VALIDATE("Lock Pricing ELA", TRUE);  //EN1.00
                            lrecSalesLine.MODIFY(TRUE);
                        /*END ELSE BEGIN
                            IF lrecSalesLine."Sales Price Source" = gjfText030 THEN BEGIN
                                lrecSalesLine."Sales Price Source" := '';
                                lrecSalesLine.VALIDATE("Lock Pricing", TRUE);  //EN1.00
                                lrecSalesLine.MODIFY(TRUE);
                            END;
                        END;*/

                    lcduCustItemSurchgMgt.PriceFromOrderRuleCombo(TRUE, grecTempOrderRuleSalesLine);
                    lcduCustItemSurchgMgt.ProcessSalesLineSurcharges(lrecSalesLine);
                END;
            UNTIL grecTempOrderRuleSalesLine.NEXT = 0;

        grecTempOrderRuleSalesLine.SETRANGE(grecTempOrderRuleSalesLine."Combination Unit Price");
    end;

    
    procedure doFromOrderSheet(pcodCustomer: Code[20]; pcodShipTo: Code[10]; pcodReqDate: Date)
    begin
        gblnFromOrderSheet := TRUE;

        gcodOrderSheetCustomer := pcodCustomer;
        gcodOrderSheetShipTo := pcodShipTo;
        gdteOrderSheetDate := pcodReqDate;
    end;

    
    procedure yogComboLinePasses(precTempOrderRuleSalesLine: Record "EN Order Rule Sales Line" temporary): Boolean
    var
        lrecSRSetup: Record "Sales & Receivables Setup";
    begin
        //<YOG43466AC>

        lrecSRSetup.GET;

        IF (
          (lrecSRSetup."Order Rule Comb Price Prio ELA"
            = lrecSRSetup."Order Rule Comb Price Prio ELA"::"Use Item Price")
        ) THEN BEGIN
            EXIT(cbLinePasses(precTempOrderRuleSalesLine));
        END;

        //Meets Combination Min. Qty. - Does not have to meet the order multiple
        IF (precTempOrderRuleSalesLine."Combination Not Setup" = FALSE) AND
           (precTempOrderRuleSalesLine."Combination Min. Qty." = FALSE) THEN BEGIN
            EXIT(TRUE);
        END;
    end;
}

