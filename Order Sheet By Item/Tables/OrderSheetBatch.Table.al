table 14228814 "Order Sheet Batch"
{
    // Copyright Axentia Solutions Corp.  1999-2010.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // //<JF00042DO>
    // 
    // JF09573AC
    //   20100410 - add fields
    //     - 23019000 Location Code

    LookupPageID = "Order Sheet Batches";

    fields
    {
        field(1; Name; Code[10])
        {
        }
        field(2; Description; Text[50])
        {
        }
        field(23019000; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Description = 'JF09573AC';
            TableRelation = Location WHERE ("Use As In-Transit"=const(false));

            trigger OnValidate()
            var
               // lcduGranuleMgmt: Codeunit Codeunit23019795; TBR
            begin
                //<JF09573AC>
             //   IF lcduGranuleMgmt.jfTestTableLicensed(DATABASE::"DSD Setup") THEN BEGIN
                  //  IF grecDSDSetup.GET THEN;
               // END;
               // grecDSDSetup.TESTFIELD("Override Loc. from Route Temp.", FALSE); TBR
                //</JF09573AC>
            end;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        grecDSDSetup: Record "DSD Setup";

    [Scope('Internal')]
    procedure jfdoGetOrderRuleItems()
    var
        lrecOrderSheetCustomer: Record "Order Sheet Customers";
        lrecOrderSheetItems: Record "Order Sheet Items";
        lrecOrderRuleDetail: Record "EN Order Rule Detail";
        lrecOrderRuleDetailLine: Record "EN Order Rule Detail Line";
        lrecItem: Record Item;
        lJFText001: Label 'Do you wish to add items from the customer order rules?';
    begin
        IF NOT CONFIRM(lJFText001, TRUE) THEN
            EXIT;

        lrecOrderSheetCustomer.SETRANGE("Order Sheet Batch Name", Name);
        IF lrecOrderSheetCustomer.FIND('-') THEN BEGIN
            REPEAT
                lrecOrderRuleDetail.SETRANGE("Sales Code", lrecOrderSheetCustomer."Sell-to Customer No.");
                lrecOrderRuleDetail.SETFILTER("Ship-To Address Code", '%1|%2', lrecOrderSheetCustomer."Ship-to Code", '');
                IF lrecOrderRuleDetail.FIND('-') THEN BEGIN
                    REPEAT
                        CASE lrecOrderRuleDetail."Item Type" OF
                            lrecOrderRuleDetail."Item Type"::"Item No.":
                                BEGIN
                                    lrecOrderSheetItems."Order Sheet Batch Name" := lrecOrderSheetCustomer."Order Sheet Batch Name";
                                    lrecOrderSheetItems."Item No." := lrecOrderRuleDetail."Item Ref. No.";
                                    lrecOrderSheetItems."Unit of Measure Code" := lrecOrderRuleDetail."Unit of Measure Code";
                                    IF NOT lrecOrderSheetItems.INSERT THEN;
                                END;
                            lrecOrderRuleDetail."Item Type"::"Item Category":
                                BEGIN
                                    //            lrecItem.SETCURRENTKEY("Item category code");
                                    lrecItem.SETRANGE("Item Category Code", lrecOrderRuleDetail."Item Ref. No.");
                                    IF lrecItem.FIND('-') THEN BEGIN
                                        REPEAT
                                            lrecOrderSheetItems."Order Sheet Batch Name" := lrecOrderSheetCustomer."Order Sheet Batch Name";
                                            lrecOrderSheetItems."Item No." := lrecItem."No.";
                                            lrecOrderSheetItems."Unit of Measure Code" := lrecOrderRuleDetail."Unit of Measure Code";
                                            IF NOT lrecOrderSheetItems.INSERT THEN;
                                        UNTIL lrecItem.NEXT = 0;
                                    END;
                                END;
                            lrecOrderRuleDetail."Item Type"::Combination:
                                BEGIN
                                    lrecOrderRuleDetailLine.SETRANGE("Sales Code", lrecOrderRuleDetail."Sales Code");
                                    lrecOrderRuleDetailLine.SETRANGE("Ship-To Address Code", lrecOrderRuleDetail."Ship-To Address Code");
                                    lrecOrderRuleDetailLine.SETRANGE("Item Type", lrecOrderRuleDetail."Item Type");
                                    lrecOrderRuleDetailLine.SETRANGE("Item Ref. No.", lrecOrderRuleDetail."Item Ref. No.");
                                    lrecOrderRuleDetailLine.SETRANGE("Start Date", lrecOrderRuleDetail."Start Date");
                                    lrecOrderRuleDetailLine.SETRANGE("Unit of Measure Code", lrecOrderRuleDetail."Unit of Measure Code");


                                    IF lrecOrderRuleDetailLine.FIND('-') THEN BEGIN
                                        REPEAT
                                            lrecOrderSheetItems."Order Sheet Batch Name" := lrecOrderSheetCustomer."Order Sheet Batch Name";
                                            lrecOrderSheetItems."Item No." := lrecOrderRuleDetailLine."Item No.";
                                            lrecOrderSheetItems."Unit of Measure Code" := lrecOrderRuleDetail."Unit of Measure Code";
                                            IF NOT lrecOrderSheetItems.INSERT THEN;
                                        UNTIL lrecOrderRuleDetailLine.NEXT = 0;
                                    END;
                                END;

                        END;
                    UNTIL lrecOrderRuleDetail.NEXT = 0;
                END;
            UNTIL lrecOrderSheetCustomer.NEXT = 0;
        END;
    end;
}

