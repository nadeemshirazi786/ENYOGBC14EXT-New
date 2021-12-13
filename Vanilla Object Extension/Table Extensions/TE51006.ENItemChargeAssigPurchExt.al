tableextension 51006 TItemChargeAssigPurchExt extends "Item Charge Assignment (Purch)"
{
    fields
    {
        field(14229400; "Initial Distribution Type ELA"; Option)
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionMembers = " ",Equal,Amount,Weight,Volume,Pallet,Quantity;
        }
        field(14229401; "Orig. Doc. Type ELA"; Option)
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Receipt,"Transfer Receipt","Return Shipment","Sales Shipment","Return Receipt","Sales Order","Sales Return Order","Item Ledger";
        }
        field(14229402; "Orig. Doc. No. ELA"; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
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
        field(14229403; "Orig. Doc. Line No. ELA"; Integer)
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
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
        field(51000; "Initial Distribution Type"; Enum DistributionType)
        {
            DataClassification = ToBeClassified;
        }
        field(51001; "Unit Cost (LCY)"; Decimal)
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(51002; "Amount To Assign (LCY)"; Decimal)
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(51003; "Orig. Doc. Type"; Enum ApplToDocType)
        {
            DataClassification = ToBeClassified;
        }
        field(51004; "Orig. Doc. No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(51005; "Orig. Doc. Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }

    }
    procedure jfCalcItemChargeLCY(pdecCurrFactor: Decimal)
    var
        lrecPurchHeader: Record "Purchase Header";
    begin
        IF lrecPurchHeader.GET("Document Type", "Document No.") THEN BEGIN
            IF lrecPurchHeader."Currency Code" <> '' THEN BEGIN
                IF pdecCurrFactor = 0 THEN
                    "Unit Cost (LCY)" := ROUND("Unit Cost" / lrecPurchHeader."Currency Factor")
                ELSE
                    "Unit Cost (LCY)" := ROUND("Unit Cost" / pdecCurrFactor);
            END ELSE BEGIN
                "Unit Cost (LCY)" := "Unit Cost";
            END;
        END;

        IF lrecPurchHeader.GET("Document Type", "Document No.") THEN BEGIN
            IF lrecPurchHeader."Currency Code" <> '' THEN BEGIN
                IF pdecCurrFactor = 0 THEN
                    "Amount To Assign (LCY)" := ROUND("Amount to Assign" / lrecPurchHeader."Currency Factor")
                ELSE
                    "Amount To Assign (LCY)" := ROUND("Amount to Assign" / pdecCurrFactor);
            END ELSE BEGIN
                "Amount To Assign (LCY)" := "Amount to Assign";
            END;
        END;

    end;

    procedure jfSetOrigDocInfo(poptOrigDocType: Enum ApplToDocType; pcodOrigDocNo: Code[20]; pintOrigDocLineNo: Integer)
    var

    begin
        goptOrigDocType := poptOrigDocType;
        gcodOrigDocNo := pcodOrigDocNo;
        gintOrigDocLineNo := pintOrigDocLineNo;

    end;

    procedure InsertItemChargeAssgnt(ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; ApplToDocType: Enum ApplToDocType; ApplToDocNo2: Code[20]; ApplToDocLineNo2: Integer; ItemNo2: Code[20]; Description2: Text[50]; VAR NextLineNo: Integer)
    var
        ItemChargeAssgntPurch2: Record "Item Charge Assignment (Purch)";
    begin
        NextLineNo := NextLineNo + 10000;

        ItemChargeAssgntPurch2.INIT;
        ItemChargeAssgntPurch2."Document Type" := ItemChargeAssgntPurch."Document Type";
        ItemChargeAssgntPurch2."Document No." := ItemChargeAssgntPurch."Document No.";
        ItemChargeAssgntPurch2."Document Line No." := ItemChargeAssgntPurch."Document Line No.";
        ItemChargeAssgntPurch2."Line No." := NextLineNo;
        ItemChargeAssgntPurch2."Item Charge No." := ItemChargeAssgntPurch."Item Charge No.";
        ItemChargeAssgntPurch2."Applies-to Doc. Type" := ApplToDocType;
        ItemChargeAssgntPurch2."Applies-to Doc. No." := ApplToDocNo2;
        ItemChargeAssgntPurch2."Applies-to Doc. Line No." := ApplToDocLineNo2;
        ItemChargeAssgntPurch2."Item No." := ItemNo2;
        ItemChargeAssgntPurch2.Description := Description2;
        ItemChargeAssgntPurch2."Unit Cost" := ItemChargeAssgntPurch."Unit Cost";

        ItemChargeAssgntPurch2."Initial Distribution Type" := ItemChargeAssgntPurch."Initial Distribution Type";

        IF gcodOrigDocNo <> '' THEN BEGIN
            ItemChargeAssgntPurch2."Orig. Doc. Type" := goptOrigDocType;
            ItemChargeAssgntPurch2."Orig. Doc. No." := gcodOrigDocNo;
            ItemChargeAssgntPurch2."Orig. Doc. Line No." := gintOrigDocLineNo;
        END ELSE BEGIN
            ItemChargeAssgntPurch2."Orig. Doc. Type" := ApplToDocType;
            ItemChargeAssgntPurch2."Orig. Doc. No." := ApplToDocNo2;
            ItemChargeAssgntPurch2."Orig. Doc. Line No." := ApplToDocLineNo2;
        END;

        ItemChargeAssgntPurch2.INSERT;
    end;

    var
        goptOrigDocType: Enum ApplToDocType;
        gcodOrigDocNo: Code[20];
        gintOrigDocLineNo: Integer;
}