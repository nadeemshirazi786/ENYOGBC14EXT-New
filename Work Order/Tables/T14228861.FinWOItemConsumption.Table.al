table 23019272 "Fin. WO Item Consumption"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF8566SHR
    //   20100520 - Add fields:
    //              30 Purchase Order No.
    //              31 Purchase Receipt No.
    //              32 Purchase Receipt Line No.
    //              33 Applies-to Entry No.
    //            - Changed field 12 name from Quanity to Quantity
    // 
    // JF10366SHR
    //   20101102 - Added new field:
    //              26 Description 2
    //            - Changed field 20 Description to normal field.

    DrillDownPageID = 23019272;
    LookupPageID = 23019272;

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {
            TableRelation = Table23019270.Field1;
        }
        field(2; "PM Proc. Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header"."Version No." WHERE (Code = FIELD ("PM Procedure Code"));
        }
        field(3; "PM WO Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
        }
        field(5; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header".Code;
        }
        field(10; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(11; "Unit of Measure"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No." = FIELD ("Item No."));
        }
        field(12; Quantity; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(15; "Planned Usage Qty."; Decimal)
        {
            Caption = 'Planned Usage Qty.';
            DecimalPlaces = 0 : 5;
        }
        field(16; "Qty. Consumed"; Decimal)
        {
            Caption = 'Qty. Consumed';
            DecimalPlaces = 0 : 5;
        }
        field(20; Description; Text[50])
        {
        }
        field(23; "Bin Code"; Code[20])
        {
            Description = 'JF00099MG';
            TableRelation = "Bin Content"."Bin Code" WHERE ("Item No." = FIELD ("Item No."),
                                                            "Variant Code" = FIELD ("Variant Code"),
                                                            "Location Code" = FIELD ("Location Code"));
        }
        field(24; "Location Code"; Code[10])
        {
            CalcFormula = Lookup (Table23019270.Field106 WHERE (Field1 = FIELD ("PM Work Order No.")));
            Description = 'JF00099MG';
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "Variant Code"; Code[10])
        {
            Description = 'JF00099MG';
            TableRelation = "Item Variant".Code WHERE ("Item No." = FIELD ("Item No."));
        }
        field(26; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            Description = 'JF10366SHR';
        }
        field(30; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            Description = 'JF8566SHR';
        }
        field(31; "Purchase Receipt No."; Code[20])
        {
            Caption = 'Purchase Receipt No.';
            Description = 'JF8566SHR';
        }
        field(32; "Purchase Receipt Line No."; Integer)
        {
            Caption = 'Purchase Receipt Line No.';
            Description = 'JF8566SHR';
        }
        field(33; "Applies-to Entry"; Integer)
        {
            Caption = 'Applies-to Entry';
            Description = 'JF8566SHR';
            TableRelation = "Item Ledger Entry"."Entry No." WHERE ("Entry No." = FIELD ("Applies-to Entry"));

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
            end;
        }
    }

    keys
    {
        key(Key1; "PM Work Order No.", "PM WO Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

