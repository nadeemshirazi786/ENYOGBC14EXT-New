table 14228835 "Phys. Inv. Journal Detail ELA"
{
    DrillDownPageID = "Phys. Inv. Journal Details ELA";
    LookupPageID = "Phys. Inv. Journal Details ELA";

    fields
    {
        field(10; "Journal Template Name"; Code[10])
        {
            TableRelation = "Item Journal Template".Name;
        }
        field(20; "Journal Batch Name"; Code[10])
        {
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(30; "Item Jnl. Line No."; Integer)
        {
            TableRelation = "Item Journal Line"."Line No." WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                                  "Journal Batch Name" = FIELD("Journal Batch Name"));
        }
        field(35; "Entry No."; Integer)
        {
        }
        field(40; "Quantity (Base) (Count)"; Decimal)
        {
            BlankZero = true;
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            var
                lrecItemJnlLine: Record "Item Journal Line";
            begin
                if "Unit of Measure Code" = '' then begin
                    lrecItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Item Jnl. Line No.");

                    "Unit of Measure Code" := lrecItemJnlLine."Unit of Measure Code";

                    "Quantity (Count)" := jfCalcQtyCount("Quantity (Base) (Count)");
                end;
            end;
        }
        field(50; "Item No."; Code[20])
        {
            Editable = false;
            TableRelation = Item;
        }
        field(60; "Location Code"; Code[10])
        {
            Editable = false;
            TableRelation = Location;
        }
        field(70; "Quantity (Count)"; Decimal)
        {
            BlankZero = true;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                "Quantity (Base) (Count)" := jfCalcQtyBase("Quantity (Count)");
            end;
        }
        field(80; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                "Quantity (Base) (Count)" := jfCalcQtyBase("Quantity (Count)");
            end;
        }
        field(90; "Created By"; Code[50])
        {
            Editable = false;
        }
        field(100; "Date Created"; Date)
        {
            Editable = false;
        }
        field(110; "Last Date Modified"; Date)
        {
            Editable = false;
        }
        field(120; "Modified By"; Code[50])
        {
            Editable = false;
        }
        field(130; Description; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
            SumIndexFields = "Quantity (Base) (Count)", "Quantity (Count)";
        }
        key(Key2; "Journal Template Name", "Journal Batch Name", "Item Jnl. Line No.")
        {
            SumIndexFields = "Quantity (Base) (Count)", "Quantity (Count)";
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        lrecPhysInvLine: Record "Item Journal Line";
    begin
        LockTable;

        if "Entry No." = 0 then
            if grecPhysInvDetail.FindLast then
                "Entry No." := grecPhysInvDetail."Entry No." + 1;

        "Created By" := UpperCase(UserId);
        "Date Created" := WorkDate;

        //<JF15103SPK>
        if "Quantity (Base) (Count)" <> 0 then
            "Quantity (Count)" := jfCalcQtyCount("Quantity (Base) (Count)")
        else
            "Quantity (Base) (Count)" := jfCalcQtyBase("Quantity (Count)");
        //</JF15103SPK>
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := WorkDate;
        "Modified By" := UpperCase(UserId);
    end;

    var
        grecPhysInvDetail: Record "Phys. Inv. Journal Detail ELA";

    [Scope('Internal')]
    procedure jfCalcQtyBase(pdecQuantity: Decimal): Decimal
    var
        lrecItem: Record Item;
        lrecUOM: Record "Unit of Measure";
        ldecConversion: Decimal;
    begin
        TestField("Unit of Measure Code");

        if lrecItem.Get("Item No.") then begin
            lrecUOM.Get("Unit of Measure Code");

            //ldecConversion := lcduUOMConstant.jmGetConversion(lrecItem,lrecUOM);

            if ldecConversion = 0 then
                ldecConversion := 1;

            exit(Round(pdecQuantity / ldecConversion, 0.00001));
        end;
    end;

    [Scope('Internal')]
    procedure jfCalcQtyCount(pdecQuantity: Decimal): Decimal
    var
        lrecItem: Record Item;
        lrecUOM: Record "Unit of Measure";
        ldecConversion: Decimal;
    begin
        TestField("Unit of Measure Code");

        if lrecItem.Get("Item No.") then begin
            lrecUOM.Get("Unit of Measure Code");

            //ldecConversion := lcduUOMConstant.jmGetConversion(lrecItem,lrecUOM);

            if ldecConversion = 0 then
                ldecConversion := 1;

            exit(Round(pdecQuantity * ldecConversion, 0.00001));
        end;
    end;
}

