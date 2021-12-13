table 14228883 "Posted Item Chg Asgnmt (Purch)"
{
    PasteIsValid = false;

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Purchase Invoice","Posted Purchase Cr.Memo";
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            TableRelation = "Purchase Line"."Line No." WHERE("Document Type" = FIELD("Document Type"),
                                                              "Document No." = FIELD("Document No."));
        }
        field(5; "Item Charge No."; Code[20])
        {
            Caption = 'Item Charge No.';
            NotBlank = true;
            TableRelation = "Item Charge";
        }
        field(6; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(7; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(8; "Qty. to Assign"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. to Assign';
            DecimalPlaces = 0 : 5;
        }
        field(9; "Qty. Assigned"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. Assigned';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(10; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
        }
        field(11; "Amount to Assign"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount to Assign';
        }
        field(12; "Applies-to Doc. Type"; Option)
        {
            Caption = 'Applies-to Doc. Type';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Receipt,"Transfer Receipt","Return Shipment","Sales Shipment","Return Receipt","Sales Order","Sales Return Order";
        }
        field(13; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
        }
        field(14; "Applies-to Doc. Line No."; Integer)
        {
            Caption = 'Applies-to Doc. Line No.';
        }
        field(15; "Applies-to Doc. Line Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Applies-to Doc. Line Amount';
        }
        field(23019600; "Initial Distribution Type"; Option)
        {
            
            OptionCaption = 'Equal,Amount,Weight,Pallet';
            OptionMembers = Equal,Amount,Weight,Pallet;
        }
        field(23019601; "Orig. Doc. Type"; Option)
        {
            
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Receipt,"Transfer Receipt","Return Shipment","Sales Shipment","Return Receipt","Sales Order","Sales Return Order";
        }
        field(23019602; "Orig. Doc. No."; Code[20])
        {
            
            TableRelation = IF ("Applies-to Doc. Type" = CONST(Order)) "Purchase Header"."No." WHERE("Document Type" = CONST(Order))
            ELSE
            IF ("Applies-to Doc. Type" = CONST(Invoice)) "Purchase Header"."No." WHERE("Document Type" = CONST(Invoice))
            ELSE
            IF ("Applies-to Doc. Type" = CONST("Return Order")) "Purchase Header"."No." WHERE("Document Type" = CONST("Return Order"))
            ELSE
            IF ("Applies-to Doc. Type" = CONST("Credit Memo")) "Purchase Header"."No." WHERE("Document Type" = CONST("Credit Memo"))
            ELSE
            IF ("Applies-to Doc. Type" = CONST(Receipt)) "Purch. Rcpt. Header"."No."
            ELSE
            IF ("Applies-to Doc. Type" = CONST("Return Shipment")) "Return Shipment Header"."No.";
        }
        field(23019603; "Orig. Doc. Line No."; Integer)
        {
            
            TableRelation = IF ("Applies-to Doc. Type" = CONST(Order)) "Purchase Line"."Line No." WHERE("Document Type" = CONST(Order),
                                                                                                       "Document No." = FIELD("Applies-to Doc. No."))
            ELSE
            IF ("Applies-to Doc. Type" = CONST(Invoice)) "Purchase Line"."Line No." WHERE("Document Type" = CONST(Invoice),
                                                                                                                                                                                         "Document No." = FIELD("Applies-to Doc. No."))
            ELSE
            IF ("Applies-to Doc. Type" = CONST("Return Order")) "Purchase Line"."Line No." WHERE("Document Type" = CONST("Return Order"),
                                                                                                                                                                                                                                                                                  "Document No." = FIELD("Applies-to Doc. No."))
            ELSE
            IF ("Applies-to Doc. Type" = CONST("Credit Memo")) "Purchase Line"."Line No." WHERE("Document Type" = CONST("Credit Memo"),
                                                                                                                                                                                                                                                                                                                                                                          "Document No." = FIELD("Applies-to Doc. No."))
            ELSE
            IF ("Applies-to Doc. Type" = CONST(Receipt)) "Purch. Rcpt. Line"."Line No." WHERE("Document No." = FIELD("Applies-to Doc. No."))
            ELSE
            IF ("Applies-to Doc. Type" = CONST("Return Shipment")) "Return Shipment Line"."Line No." WHERE("Document No." = FIELD("Applies-to Doc. No."));
        }
        field(23019604; "Unit Cost (LCY)"; Decimal)
        {
            
        }
        field(23019605; "Amount To Assign (LCY)"; Decimal)
        {
            
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Document Line No.", "Line No.")
        {
            Clustered = true;
            MaintainSIFTIndex = false;
            SumIndexFields = "Qty. to Assign", "Qty. Assigned", "Amount to Assign";
        }
        key(Key2; "Applies-to Doc. Type", "Applies-to Doc. No.", "Applies-to Doc. Line No.")
        {
            MaintainSQLIndex = false;
            SumIndexFields = "Amount to Assign", "Amount To Assign (LCY)";
        }
        key(Key3; "Applies-to Doc. Type")
        {
            MaintainSQLIndex = false;
        }
        key(Key4; "Orig. Doc. Type", "Orig. Doc. No.", "Orig. Doc. Line No.", "Line No.")
        {
            SumIndexFields = "Amount to Assign", "Amount To Assign (LCY)";
        }
        key(Key5; "Orig. Doc. Type", "Orig. Doc. No.", "Item Charge No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key6; "Applies-to Doc. Type", "Applies-to Doc. No.", "Item Charge No.")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount to Assign", "Amount To Assign (LCY)";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestField("Qty. Assigned", 0);
    end;

    var
        Text000: Label 'You cannot assign item charges to the %1 because it has been invoiced. Instead you can get the posted document line and then assign the item charge to that line.';
        PurchLine: Record "Purchase Line";
        Currency: Record Currency;

    [Scope('Internal')]
    procedure PurchLineInvoiced(): Boolean
    begin
        if "Applies-to Doc. Type" <> "Document Type" then
            exit(false);
        PurchLine.Get("Applies-to Doc. Type", "Applies-to Doc. No.", "Applies-to Doc. Line No.");
        exit(PurchLine.Quantity = PurchLine."Quantity Invoiced");
    end;

    [Scope('Internal')]
    procedure ReverseSign()
    begin

        "Qty. to Assign" := -"Qty. to Assign";
        "Qty. Assigned" := -"Qty. Assigned";
        "Amount to Assign" := -"Amount to Assign";
        "Amount To Assign (LCY)" := -"Amount To Assign (LCY)";
    end;
}

