table 14229406 "Cancelled Rebate Line ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - new table to be used for rebates that have been cancelled


    fields
    {
        field(10; "Line No."; Integer)
        {
        }
        field(20; "Rebate Code"; Code[20])
        {
            Editable = true;
            TableRelation = "Cancelled Rebate Header ELA".Code;
        }
        field(30; Source; Option)
        {
            OptionCaption = 'Customer,Item,Salesperson,Dimension';
            OptionMembers = Customer,Item,Salesperson,Dimension;
        }
        field(40; Type; Option)
        {
            OptionCaption = 'No.,Sub-type';
            OptionMembers = "No.","Sub-type";
        }
        field(50; "Sub-Type"; Option)
        {
            OptionCaption = ' ,Rebate Group,Category Code,Product Group';
            OptionMembers = " ","Rebate Group","Category Code","Product Group";

            trigger OnValidate()
            var
                lcon0001: Label 'Sub-Type must be Rebate Group, Category Code or Product Group.';
            begin
            end;
        }
        field(60; "Dimension Code"; Code[20])
        {
            TableRelation = Dimension;
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
            // lrecProductGroup: Record "Product Group";
            begin
            end;

            trigger OnValidate()
            var
                lrecItem: Record Item;
                lrecCustomer: Record Customer;
                lrecRebateGroup: Record "Rebate Group ELA";
                lrecSalesPerson: Record "Salesperson/Purchaser";
                lrecDimValue: Record "Dimension Value";
                lrecItemCategory: Record "Item Category";
            // lrecProductGroup: Record "Product Group";
            begin
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
            end;
        }
        field(90; Description; Text[50])
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

    var
        grecRebateHeader: Record "Cancelled Rebate Header ELA";


    procedure GetRebateHeader()
    begin
        grecRebateHeader.Get("Rebate Code");
    end;
}

