table 14229428 "Purchase Rebate Line ELA"
{
    // ENRE1.00 2021-09-08 AJ

    // 
    // ENRE1.00
    //    - New Field
    //    - Guaranteed Unit Cost (LCY)
    //    - Guaranteed Cost UOM Code
    // 
    // ENRE1.00
    //    - moved "Rebate Type"::"Guaranteed Cost Deal" to a "Calculation Basis"
    // 

    // ENRE1.00  - Fixed issue that prevent user form creating Purchase Rebates based on Item Category Code


    fields
    {
        field(10; "Line No."; Integer)
        {
        }
        field(20; "Purchase Rebate Code"; Code[20])
        {
            Editable = true;
            TableRelation = "Purchase Rebate Header ELA";
        }
        field(30; Source; Option)
        {
            OptionCaption = 'Item,Dimension';
            OptionMembers = Item,Dimension;

            trigger OnValidate()
            begin
                if Rec.Source <> xRec.Source then begin
                    Clear(Type);
                    Clear("Sub-Type");
                    Clear("Dimension Code");
                    Clear(Value);
                    Clear(Description);
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
                    Clear(Description);
                    if (Source = Source::Dimension) then begin
                        TestField(Type, Type::"No.");
                    end;
                    if (Source = Source::Dimension) and (Type = Type::"No.") then begin
                        "Sub-Type" := "Sub-Type"::" ";
                    end;
                    if ((Source = Source::Item) or (Source = Source::Dimension))
                      and (Type = Type::"No.") then begin
                        "Sub-Type" := "Sub-Type"::" ";
                    end;
                    if ((Source = Source::Item))
                       and (Type = Type::"Sub-type") then begin
                        "Sub-Type" := "Sub-Type"::"Rebate Group";
                    end;

                    if (Source = Source::Dimension) and (Type = Type::"Sub-type") then begin
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
                lcon0001: Label 'Sub-Type must be Rebate Group, Category Code';
            begin
                if Rec."Sub-Type" <> xRec."Sub-Type" then begin
                    Clear("Dimension Code");
                    Clear(Value);
                    Clear(Description);
                    if ((Source = Source::Item) or (Source = Source::Dimension))
                      and (Type = Type::"No.") then begin
                        TestField("Sub-Type", "Sub-Type"::" ");
                    end;
                    if (Source = Source::Item)
                      and (Type = Type::"Sub-type") then begin
                        //<ENRE1.00>
                        if not ("Sub-Type" in ["Sub-Type"::"Rebate Group", "Sub-Type"::"Category Code"]) then begin
                            FieldError("Sub-Type", lcon0001);
                        end;
                        //</ENRE1.00>
                    end;
                    if (Source = Source::Dimension) and (Type = Type::"Sub-type") then begin
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
                    lrecSalesPerson.Reset;
                    lrecDimValue.Reset;

                    Clear(Description);

                    case Source of
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
                end;
            end;
        }
        field(90; Description; Text[100])
        {
            Editable = false;
        }
        field(100; Include; Boolean)
        {
        }
        field(110; "Guaranteed Unit Cost (LCY)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Guaranteed Unit Cost ($)';
            DecimalPlaces = 2 : 5;
            Description = 'ENRE1.00';

            trigger OnValidate()
            var
                lrecPurchRebateHeader: Record "Purchase Rebate Header ELA";
                lrecItem: Record Item;
            begin
                //<ENRE1.00>
                if "Guaranteed Unit Cost (LCY)" <> 0 then begin
                    lrecPurchRebateHeader.Get("Purchase Rebate Code");
                    //<ENRE1.00>
                    lrecPurchRebateHeader.TestField("Calculation Basis",
                                                     lrecPurchRebateHeader."Calculation Basis"::"Guaranteed Cost Deal");
                    //</ENRE1.00>
                    TestField(Source, Source::Item);
                    if ((Source = Source::Item) and (Type = Type::"No.")) then begin
                        if lrecItem.Get(Value) and (lrecItem."Purch. Unit of Measure" <> '') then
                            Validate("Guaranteed Cost UOM Code", lrecItem."Purch. Unit of Measure");
                    end;
                end;
                //</ENRE1.00>
            end;
        }
        field(111; "Guaranteed Cost UOM Code"; Code[10])
        {
            Description = 'ENRE1.00';
            TableRelation = IF (Source = CONST(Item),
                                Type = CONST("No.")) "Item Unit of Measure".Code WHERE("Item No." = FIELD(Value))
            ELSE
            IF (Source = CONST(Item),
                                         Type = CONST("Sub-type")) "Unit of Measure".Code;

            trigger OnValidate()
            var
                lrecPurchRebateHeader: Record "Purchase Rebate Header ELA";
            begin
                //<ENRE1.00>
                if "Guaranteed Cost UOM Code" <> '' then begin
                    lrecPurchRebateHeader.Get("Purchase Rebate Code");
                    //<ENRE1.00>
                    lrecPurchRebateHeader.TestField("Calculation Basis",
                                                     lrecPurchRebateHeader."Calculation Basis"::"Guaranteed Cost Deal");
                    //</ENRE1.00>
                    TestField(Source, Source::Item);
                end;
                //</ENRE1.00>
            end;
        }
    }

    keys
    {
        key(Key1; "Purchase Rebate Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; Source, Type, "Sub-Type", "Dimension Code", Value, Include)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Include := true;
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
        grecRebateHeader.Get("Purchase Rebate Code");
    end;
}

