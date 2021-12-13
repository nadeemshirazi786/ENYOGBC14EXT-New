table 14229437 "Rebate Line ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - Clear Rebate Value when Source Changes. Only allow rebate values to be entere where source is Item or Customer.
    // 
    // ENRE1.00
    //    - rework code for checking promotion rebate link


    fields
    {
        field(10; "Line No."; Integer)
        {
        }
        field(20; "Rebate Code"; Code[20])
        {
            Editable = true;
            TableRelation = "Rebate Header ELA";
        }
        field(30; Source; Option)
        {
            OptionCaption = 'Customer,Item,Salesperson,Dimension';
            OptionMembers = Customer,Item,Salesperson,Dimension;

            trigger OnValidate()
            begin
                if Rec.Source <> xRec.Source then begin
                    Clear(Type);
                    Clear("Sub-Type");
                    Clear("Dimension Code");
                    Clear(Value);
                    Clear("Ship-To Address Code");
                    Clear(Description);
                    //<ENRE1.00>
                    Clear("Rebate Value");
                    //</ENRE1.00>
                    if (Source = Source::Dimension) then begin
                        Type := Type::"No.";
                    end;
                end;
            end;
        }
        field(40; Type; Option)
        {
            OptionCaption = 'No.,Sub-type';
            OptionMembers = "No.","Sub-type";

            trigger OnValidate()
            begin
                if Rec.Type <> xRec.Type then begin
                    Clear("Sub-Type");
                    Clear("Dimension Code");
                    Clear(Value);
                    Clear("Ship-To Address Code");
                    Clear(Description);
                    if (Source = Source::Dimension) then begin
                        TestField(Type, Type::"No.");
                    end;
                    if (Source = Source::Dimension) and (Type = Type::"No.") then begin
                        "Sub-Type" := "Sub-Type"::" ";
                    end;
                    if ((Source = Source::Customer) or (Source = Source::Item) or (Source = Source::Salesperson))
                      and (Type = Type::"No.") then begin
                        "Sub-Type" := "Sub-Type"::" ";
                    end;
                    if ((Source = Source::Customer) or (Source = Source::Salesperson))
                      and (Type = Type::"Sub-type") then begin
                        "Sub-Type" := "Sub-Type"::"Rebate Group";
                    end;
                    if (Source = Source::Item) and (Type = Type::"Sub-type") then begin
                        "Sub-Type" := "Sub-Type"::"Rebate Group";
                    end;
                end;
            end;
        }
        field(50; "Sub-Type"; Option)
        {
            OptionCaption = ' ,Rebate Group,Category Code';
            OptionMembers = " ","Rebate Group","Category Code";

            trigger OnValidate()
            var
                lcon0001: Label 'Sub-Type must be Rebate Group, Category Code or Product Group.';
            begin
                if Rec."Sub-Type" <> xRec."Sub-Type" then begin
                    Clear("Dimension Code");
                    Clear(Value);
                    Clear("Ship-To Address Code");
                    Clear(Description);
                    if ((Source = Source::Customer) or (Source = Source::Item) or (Source = Source::Salesperson))
                      and (Type = Type::"No.") then begin
                        TestField("Sub-Type", "Sub-Type"::" ");
                    end;
                    if ((Source = Source::Customer) or (Source = Source::Salesperson))
                      and (Type = Type::"Sub-type") then begin
                        TestField("Sub-Type", "Sub-Type"::"Rebate Group");
                    end;
                    if (Source = Source::Item) and (Type = Type::"Sub-type") then begin
                        if ("Sub-Type" = "Sub-Type"::" ") then begin
                            Error(lcon0001);
                        end;
                    end;
                    if (Source = Source::Dimension) then begin
                        TestField(Type, Type::"No.");
                        TestField("Sub-Type", "Sub-Type"::" ");
                    end;
                end;
            end;
        }
        field(60; "Dimension Code"; Code[20])
        {
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                if Rec."Dimension Code" <> xRec."Dimension Code" then begin
                    Clear(Value);
                    Clear("Ship-To Address Code");
                    Clear(Description);

                    TestField(Source, Source::Dimension);
                    TestField(Type, Type::"No.");
                    TestField("Sub-Type", "Sub-Type"::" ");
                end;
            end;
        }
        field(70; Value; Code[20])
        {

            trigger OnLookup()
            var
                lrecItem: Record Item;
                lrecCustomer: Record Customer;
                lrecRebateGroup: Record "Rebate Group ELA";
                lrecSalesPerson: Record "Salesperson/Purchaser";
                lrecDimValue: Record "Dimension Value";
                lrecItemCategory: Record "Item Category";
            begin
                lrecItem.Reset;
                lrecCustomer.Reset;
                lrecSalesPerson.Reset;
                lrecDimValue.Reset;
                lrecRebateGroup.Reset;
                lrecItemCategory.Reset;


                case Source of
                    Source::Customer:
                        begin
                            if Type = Type::"No." then begin
                                if Value <> '' then
                                    lrecCustomer."No." := Value;

                                if not lrecCustomer.Find('=') then
                                    lrecCustomer.Find('-');

                                if (PAGE.RunModal(PAGE::"Customer List", lrecCustomer) = ACTION::LookupOK) then
                                    Validate(Value, lrecCustomer."No.");

                            end else
                                if Type = Type::"Sub-type" then begin
                                    if Value <> '' then
                                        lrecRebateGroup.Code := Value;

                                    if not lrecRebateGroup.Find('=') then
                                        lrecRebateGroup.Find('-');

                                    if (PAGE.RunModal(PAGE::"Rebate Groups ELA", lrecRebateGroup) = ACTION::LookupOK) then
                                        Validate(Value, lrecRebateGroup.Code);

                                end;
                        end;
                    Source::Salesperson:
                        begin
                            if Type = Type::"No." then begin
                                if Value <> '' then
                                    lrecSalesPerson.Code := "Dimension Code";

                                if not lrecSalesPerson.Find('=') then
                                    lrecSalesPerson.Find('-');

                                if (PAGE.RunModal(PAGE::"Salespersons/Purchasers", lrecSalesPerson) = ACTION::LookupOK) then
                                    Validate(Value, lrecSalesPerson.Code);

                            end else
                                if Type = Type::"Sub-type" then begin

                                    if Value <> '' then
                                        lrecRebateGroup.Code := Value;

                                    if not lrecRebateGroup.Find('=') then
                                        lrecRebateGroup.Find('-');

                                    if (PAGE.RunModal(PAGE::"Rebate Groups ELA", lrecRebateGroup) = ACTION::LookupOK) then
                                        Validate(Value, lrecRebateGroup.Code);
                                end;
                        end;
                    Source::Item:
                        begin
                            if Type = Type::"No." then begin
                                if Value <> '' then
                                    lrecItem."No." := Value;

                                if not lrecItem.Find('=') then
                                    lrecItem.Find('-');

                                if (PAGE.RunModal(PAGE::"Item List", lrecItem) = ACTION::LookupOK) then
                                    Validate(Value, lrecItem."No.");

                            end else
                                if Type = Type::"Sub-type" then begin
                                    case "Sub-Type" of
                                        "Sub-Type"::"Rebate Group":
                                            begin
                                                if Value <> '' then
                                                    lrecRebateGroup.Code := Value;
                                                if not lrecRebateGroup.Find('=') then
                                                    lrecRebateGroup.Find('-');

                                                if (PAGE.RunModal(PAGE::"Rebate Groups ELA", lrecRebateGroup) = ACTION::LookupOK) then
                                                    Validate(Value, lrecRebateGroup.Code);
                                            end;
                                        "Sub-Type"::"Category Code":
                                            begin
                                                if Value <> '' then
                                                    lrecItemCategory.Code := Value;

                                                if not lrecItemCategory.Find('=') then
                                                    lrecItemCategory.Find('-');

                                                if (PAGE.RunModal(PAGE::"Item Categories", lrecItemCategory) = ACTION::LookupOK) then
                                                    Validate(Value, lrecItemCategory.Code);
                                            end;

                                    end;
                                end;
                        end;
                    Source::Dimension:
                        begin
                            lrecDimValue.Reset;
                            lrecDimValue.SetRange("Dimension Code", "Dimension Code");
                            if Value <> '' then begin
                                lrecDimValue.Code := Value;
                            end;

                            if not lrecDimValue.Find('=') then begin
                                lrecDimValue.Find('-');
                            end;

                            if (PAGE.RunModal(PAGE::"Dimension Values", lrecDimValue) = ACTION::LookupOK) then
                                Validate(Value, lrecDimValue.Code);
                        end;
                end;
            end;

            trigger OnValidate()
            var
                lrecItem: Record Item;
                lrecCustomer: Record Customer;
                lrecRebateGroup: Record "Rebate Group ELA";
                lrecSalesPerson: Record "Salesperson/Purchaser";
                lrecDimValue: Record "Dimension Value";
                lrecItemCategory: Record "Item Category";
            begin
                if Value <> '' then begin
                    lrecItem.Reset;
                    lrecCustomer.Reset;
                    lrecRebateGroup.Reset;
                    lrecItemCategory.Reset;
                    //<ENRE1.00>
                    // Code deleted
                    //</ENRE1.00>
                    lrecSalesPerson.Reset;
                    lrecDimValue.Reset;

                    Clear("Ship-To Address Code");
                    Clear(Description);

                    case Source of
                        Source::Customer:
                            begin
                                if Type = Type::"No." then begin
                                    lrecCustomer.Get(Value);
                                    Description := lrecCustomer.Name;
                                end else
                                    if Type = Type::"Sub-type" then begin
                                        lrecRebateGroup.Get(Value);
                                        Description := lrecRebateGroup.Description;
                                    end;
                            end;
                        Source::Salesperson:
                            begin
                                if Type = Type::"No." then begin
                                    lrecSalesPerson.Get(Value);
                                    Description := lrecSalesPerson.Name;
                                end else
                                    if Type = Type::"Sub-type" then begin
                                        lrecRebateGroup.Get(Value);
                                        Description := lrecRebateGroup.Description;
                                    end;
                            end;
                        Source::Item:
                            begin
                                if Type = Type::"No." then begin
                                    lrecItem.Get(Value);
                                    Description := lrecItem.Description;
                                end else
                                    if Type = Type::"Sub-type" then begin
                                        case "Sub-Type" of
                                            "Sub-Type"::"Rebate Group":
                                                begin
                                                    lrecRebateGroup.Get(Value);
                                                    Description := lrecRebateGroup.Description;
                                                end;
                                            "Sub-Type"::"Category Code":
                                                begin
                                                    lrecItemCategory.Get(Value);
                                                    Description := lrecItemCategory.Description;
                                                end;
                                        end;
                                    end;
                            end;
                        Source::Dimension:
                            begin
                                lrecDimValue.Get("Dimension Code", Value);
                                Description := lrecDimValue.Name;
                            end;
                    end;
                end else begin
                    Description := '';
                    "Ship-To Address Code" := '';
                end;
            end;
        }
        field(80; "Ship-To Address Code"; Code[10])
        {
            TableRelation = IF (Source = CONST(Customer),
                                Type = CONST("No.")) "Ship-to Address".Code WHERE("Customer No." = FIELD(Value));

            trigger OnLookup()
            var
                lrecShiptoAddress: Record "Ship-to Address";
            begin
                lrecShiptoAddress.Reset;
                if Value <> '' then begin
                    if (Source = Source::Customer) and (Type = Type::"No.") and ("Sub-Type" = "Sub-Type"::" ") then begin
                        lrecShiptoAddress.SetRange("Customer No.", Value);

                        if (PAGE.RunModal(PAGE::"Ship-to Address List", lrecShiptoAddress) = ACTION::LookupOK) then
                            Validate("Ship-To Address Code", lrecShiptoAddress.Code);
                    end;
                end;
            end;

            trigger OnValidate()
            begin
                TestField(Source, Source::Customer);
                TestField(Type, Type::"No.");
                TestField("Sub-Type", "Sub-Type"::" ");
            end;
        }
        field(90; Description; Text[100])
        {
            Editable = false;
        }
        field(100; Include; Boolean)
        {
        }
        field(110; "Rebate Value"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                GetRebateHeader;

                if grecRebateHeader."Calculation Basis" = grecRebateHeader."Calculation Basis"::"Pct. Sale($)" then
                    if "Rebate Value" > 100 then
                        Error(gconText002, grecRebateHeader.Code);

                if grecRebateHeader."Rebate Type" = grecRebateHeader."Rebate Type"::"Lump Sum" then
                    grecRebateHeader.FieldError("Rebate Type");

                //<ENRE1.00>
                if Source in [Source::Salesperson, Source::Dimension] then begin
                    Error(gconText003, Source);
                end;
                //</ENRE1.00>
            end;
        }
    }

    keys
    {
        key(Key1; "Rebate Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; Source, Type, "Sub-Type", "Dimension Code", Value, "Ship-To Address Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //<ENRE1.00>
        TestJobLink;
        //</ENRE1.00>
    end;

    trigger OnInsert()
    begin
        Include := true;

        //<ENRE1.00>
        TestJobLink;
        //</ENRE1.00>
    end;

    trigger OnModify()
    begin
        //<ENRE1.00>
        TestJobLink;
        //</ENRE1.00>
    end;

    trigger OnRename()
    begin
        //<ENRE1.00>
        TestJobLink;
        //</ENRE1.00>
    end;

    var
        grecRebateSetup: Record "Rebate Header ELA";
        grecTmpRebate: Record "Rebate Header ELA" temporary;
        grecRebateHeader: Record "Rebate Header ELA";
        gconText002: Label 'Rebate value for %1 cannot be greater than 100.';
        gconText003: Label 'Rebate Values cannot be entered at that line level when Source equals %1. Enter a Rebate Value in the header.';
        gconText004: Label 'You cannot make changes or delete this rebate since it is linked to a promotinal job.';
        gblnJobLinkSuspended: Boolean;


    procedure GetRebateHeader()
    begin
        grecRebateHeader.Get("Rebate Code");
    end;

    local procedure TestJobLink()
    begin
        //<ENRE1.00>
        if gblnJobLinkSuspended then
            exit;

        GetRebateHeader;

        grecRebateHeader.TestField("Job No.", '');
        //<ENRE1.00>
    end;


    procedure SuspendJobLinkCheck(pblnSuspend: Boolean)
    begin
        //<ENRE1.00>
        gblnJobLinkSuspended := pblnSuspend;
        //</ENRE1.00>
    end;
}

