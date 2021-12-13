tableextension 14229632 "EN LT LotNoInformation EXT ELA" extends "Lot No. Information"
{


    fields
    {
        field(14229150; "Expiration Date ELA"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                IF "Expiration Date ELA" = xRec."Expiration Date ELA" THEN
                    EXIT;
                Item.GET("Item No.");
                ItemTrackingCode.GET(Item."Item Tracking Code");
                IF ItemTrackingCode."Man. Expir. Date Entry Reqd." THEN
                    TESTFIELD("Expiration Date ELA");

                IF ("Creation Date ELA" <> 0D) AND ("Expiration Date ELA" <> 0D) AND ("Expiration Date ELA" < "Creation Date ELA") THEN
                    ERROR(BeforeDateErrorText, FIELDCAPTION("Expiration Date ELA"), FIELDCAPTION("Creation Date ELA"));

                IF (GUIALLOWED) AND (CurrFieldNo = FIELDNO("Expiration Date ELA")) THEN
                    IF NOT CONFIRM(ConfirmDateChangeTxt, FALSE, FIELDCAPTION("Expiration Date ELA"), xRec."Expiration Date ELA", "Expiration Date ELA") THEN
                        ERROR(UpdateInterruptErrorText);

                ItemLedgerEntry.RESET;
                ItemLedgerEntry.SETCURRENTKEY("Item No.", "Variant Code", "Lot No.");
                ItemLedgerEntry.SETRANGE("Item No.", "Item No.");
                ItemLedgerEntry.SETRANGE("Variant Code", "Variant Code");
                ItemLedgerEntry.SETRANGE("Lot No.", "Lot No.");
                ItemLedgerEntry.SETRANGE(Positive, TRUE);
                ItemLedgerEntry.MODIFYALL("Expiration Date", "Expiration Date ELA");

                WhseEntry.RESET;
                WhseEntry.SETCURRENTKEY("Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.");
                WhseEntry.SETRANGE("Item No.", "Item No.");
                WhseEntry.SETRANGE("Variant Code", "Variant Code");
                WhseEntry.SETRANGE("Lot No.", "Lot No.");
                IF NOT WhseEntry.ISEMPTY THEN
                    WhseEntry.MODIFYALL("Expiration Date", "Expiration Date ELA");
            end;

        }
        field(14229151; "Creation Date ELA"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                IF GUIALLOWED THEN
                    xRec.TESTFIELD("Creation Date ELA", 0D);

                IF "Creation Date ELA" > TODAY THEN
                    FIELDERROR("Creation Date ELA", Text14228850);
                IF ("Document Date ELA" <> 0D) AND ("Creation Date ELA" > "Document Date ELA") THEN
                    ERROR(BeforeDateErrorText, FIELDCAPTION("Document Date ELA"), FIELDCAPTION("Creation Date ELA"));

                IF (GUIALLOWED) AND (CurrFieldNo = FIELDNO("Creation Date ELA")) THEN
                    IF NOT CONFIRM(ConfirmDateChangeTxt, FALSE, FIELDCAPTION("Creation Date ELA"), xRec."Creation Date ELA", "Creation Date ELA") THEN
                        ERROR(UpdateInterruptErrorText);

            end;

        }
        field(14229152; "Document Date ELA"; Date)
        {
            Caption = 'Document Date';
            DataClassification = ToBeClassified;
            Editable = false;

        }

        field(14229153; "Source Type ELA"; Option)
        {
            Caption = 'Source Type';
            DataClassification = ToBeClassified;
            OptionMembers = ,Customer,Vendor,Item;
            Editable = false;


        }

        field(14229154; "Source No. ELA"; code[20])
        {
            Caption = 'Source No.';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = IF ("Source Type ELA" = CONST(Customer)) Customer ELSE
            IF ("Source Type ELA" = CONST(Vendor)) Vendor;

        }

        field(14229155; "Item Category Code ELA"; code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Item Category";

        }
        field(14229156; "Posted ELA"; Boolean)
        {
            Caption = 'Posted';
            DataClassification = ToBeClassified;
            Editable = false;

        }
        field(14229157; "Supplier Lot No. ELA"; code[20])
        {
            Caption = 'Supplier Lot No.';
            DataClassification = ToBeClassified;

        }
        field(14229158; "Country/Regn of Orign Code ELA"; code[20])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region";
            trigger OnValidate()
            begin

                IF "Country/Regn of Orign Code ELA" = '' THEN BEGIN
                    Item.GET("Item No.");

                END;
            end;

        }
        field(14229159; "Document No. ELA"; code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
            Editable = false;

        }
        field(14229160; "Expected Release Date ELA"; Date)
        {
            Caption = 'Expected Release Date';
            DataClassification = ToBeClassified;

        }
        field(14229161; "Release Date ELA"; Date)
        {
            Caption = 'Release Date';
            DataClassification = ToBeClassified;
            Editable = false;
            trigger OnValidate()
            begin
                ItemLedgerEntry.RESET;
                ItemLedgerEntry.SETCURRENTKEY("Item No.", "Variant Code", "Lot No.");
                ItemLedgerEntry.SETRANGE("Item No.", "Item No.");
                ItemLedgerEntry.SETRANGE("Variant Code", "Variant Code");
                ItemLedgerEntry.SETRANGE("Lot No.", "Lot No.");
                ItemLedgerEntry.SETRANGE(Positive, TRUE);
                ItemLedgerEntry.MODIFYALL("Release Date ELA", "Release Date ELA");

            end;

        }
        field(14229162; "Lot Status Code ELA"; code[20])
        {
            Caption = 'Lot Status Code';
            DataClassification = ToBeClassified;

        }
    }


    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemLedgerEntry: Record "Item Ledger Entry";
        WhseEntry: Record "Warehouse Entry";
        ConfirmDateChangeTxt: TextConst ENU = 'Do you want to change the %1 from %2 to %3?.';
        UpdateInterruptErrorText: TextConst ENU = 'The update has been interrupted to respect the warning.';
        BeforeDateErrorText: TextConst ENU = '%1 may not be before %2.';
        Text14228850: TextConst ENU = 'may not be in the future';
        Text37002000: TextConst ENU = 'You cannot rename a %1.';
        Text37002001: TextConst ENU = 'may not be in the future';
        Text37002002: TextConst ENU = 'may not be changed from %1';
        Text37002003: TextConst ENU = 'may not be changed to %1';


}