table 23019252 "PM Item Consumption"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF10366SHR
    //   20101102 - Added new field:
    //              26 Description 2
    //            - Changed field 20 Description to normal field. COde to populate both field 20 and 26

    DrillDownPageID = 23019252;
    LookupPageID = 23019252;

    fields
    {
        field(1; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header".Code;
        }
        field(2; "Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header"."Version No." WHERE (Code = FIELD ("PM Procedure Code"));
        }
        field(3; "PM Procedure Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
            Description = 'DO NOT USE Field No. 5';
        }
        field(10; "Item No."; Code[20])
        {
            TableRelation = Item;

            trigger OnValidate()
            begin
                if grecItem.Get("Item No.") then begin
                    Validate("Unit of Measure", grecItem."Base Unit of Measure");
                    "Inventory Posting Group" := grecItem."Inventory Posting Group";
                    "Gen. Prod. Posting Group" := grecItem."Gen. Prod. Posting Group";
                    //<JF10366SHR>
                    Description := grecItem.Description;
                    "Description 2" := grecItem."Description 2";
                    //</JF10366SHR>
                end else begin
                    "Unit of Measure" := '';
                    "Inventory Posting Group" := '';
                    "Gen. Prod. Posting Group" := '';
                    "Qty. per Unit of Measure" := 0;
                    //<JF10366SHR>
                    Description := '';
                    "Description 2" := '';
                    //</JF10366SHR>
                end;
            end;
        }
        field(11; "Unit of Measure"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No." = FIELD ("Item No."));

            trigger OnValidate()
            begin
                if grecItemUOM.Get("Item No.", "Unit of Measure") then begin
                    "Qty. per Unit of Measure" := grecItemUOM."Qty. per Unit of Measure";
                end;
            end;
        }
        field(12; "Quantity Installed"; Decimal)
        {
            Caption = 'Quantity Installed';
            DecimalPlaces = 0 : 5;
        }
        field(13; "Qty. per Unit of Measure"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(15; "Planned Usage Qty."; Decimal)
        {
            Caption = 'Planned Usage Qty.';
            DecimalPlaces = 0 : 5;
        }
        field(20; Description; Text[50])
        {
            FieldClass = Normal;
        }
        field(21; "Inventory Posting Group"; Code[10])
        {
            TableRelation = "Inventory Posting Group";
        }
        field(22; "Gen. Prod. Posting Group"; Code[10])
        {
            TableRelation = "Gen. Product Posting Group";
        }
        field(26; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            Description = 'JF10366SHR';
        }
    }

    keys
    {
        key(Key1; "PM Procedure Code", "Version No.", "PM Procedure Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckPMHeaderStatus;

        if HasLinks then
            DeleteLinks;
    end;

    trigger OnInsert()
    begin
        CheckPMHeaderStatus;
    end;

    trigger OnModify()
    begin
        CheckPMHeaderStatus;
    end;

    trigger OnRename()
    begin
        CheckPMHeaderStatus;
    end;

    var
        grecItem: Record Item;
        grecItemUOM: Record "Item Unit of Measure";

    [Scope('Internal')]
    procedure CheckPMHeaderStatus()
    var
        lrecPMProc: Record "PM Procedure Header";
    begin
        lrecPMProc.Get("PM Procedure Code", "Version No.");
        lrecPMProc.CheckStatus;
    end;
}

