table 14229435 "Rebate Journal Line ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //   20110324 - check for blocked rebates
    // 
    // ENRE1.00
    //   20110509 - New field:
    //              110 Adjustment
    // 
    // ENRE1.00
    //   20111104 - prevent rebates with rebate type commodity being selected
    // 


    Caption = 'Rebate Journal Line';
    DrillDownPageID = "Rebate Journal ELA";
    LookupPageID = "Rebate Journal ELA";

    fields
    {
        field(1; "Rebate Batch Name"; Code[10])
        {
            Caption = 'Rebate Batch Name';
            TableRelation = "Rebate Batch ELA".Name;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Adjustment';
            OptionMembers = Adjustment;
        }
        field(15; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(16; "Applies-To Vendor No."; Code[20])
        {
            TableRelation = Vendor;
        }
        field(17; "Applies-To Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(18; "Applies-To Source Type"; Option)
        {
            OptionCaption = 'Posted Sales Invoice,Posted Sales Cr. Memo,Customer,Posted Purch. Invoice,Posted Purch. Cr. Memo,Vendor';
            OptionMembers = "Posted Sales Invoice","Posted Sales Cr. Memo",Customer,"Posted Purch. Invoice","Posted Purch. Cr. Memo",Vendor;

            trigger OnValidate()
            begin
                Clear("Applies-To Source No.");
                Clear("Applies-To Source Line No.");
            end;
        }
        field(19; "Applies-To Source No."; Code[20])
        {
            TableRelation = IF ("Applies-To Source Type" = CONST("Posted Sales Cr. Memo")) "Sales Cr.Memo Header"."No." WHERE("Bill-to Customer No." = FIELD("Applies-To Customer No."))
            ELSE
            IF ("Applies-To Source Type" = CONST("Posted Sales Invoice")) "Sales Invoice Header"."No." WHERE("Bill-to Customer No." = FIELD("Applies-To Customer No."))
            ELSE
            IF ("Applies-To Source Type" = CONST(Customer)) Customer."No.";
        }
        field(20; "Applies-To Source Line No."; Integer)
        {
            TableRelation = IF ("Applies-To Source Type" = CONST("Posted Sales Cr. Memo")) "Sales Cr.Memo Line"."Line No." WHERE("Document No." = FIELD("Applies-To Source No."))
            ELSE
            IF ("Applies-To Source Type" = CONST("Posted Sales Invoice")) "Sales Invoice Line"."Line No." WHERE("Document No." = FIELD("Applies-To Source No."));

            trigger OnLookup()
            var
                lrecSalesInvLine: Record "Sales Invoice Line";
                lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
            begin
                case "Applies-To Source Type" of
                    "Applies-To Source Type"::"Posted Sales Invoice":
                        begin
                            lrecSalesInvLine.FilterGroup(10);
                            lrecSalesInvLine.SetRange("Document No.", "Applies-To Source No.");
                            lrecSalesInvLine.FilterGroup(0);

                            if PAGE.RunModal(PAGE::"Posted Sales Invoice Lines", lrecSalesInvLine) = ACTION::LookupOK then begin
                                Validate("Applies-To Source Line No.", lrecSalesInvLine."Line No.");
                            end;
                        end;
                    "Applies-To Source Type"::"Posted Sales Cr. Memo":
                        begin
                            lrecSalesCrMemoLine.FilterGroup(10);
                            lrecSalesCrMemoLine.SetRange("Document No.", "Applies-To Source No.");
                            lrecSalesCrMemoLine.FilterGroup(0);

                            if PAGE.RunModal(PAGE::"Posted Sales Credit Memo Lines", lrecSalesCrMemoLine) = ACTION::LookupOK then begin
                                Validate("Applies-To Source Line No.", lrecSalesCrMemoLine."Line No.");
                            end;
                        end;
                end;
            end;

            trigger OnValidate()
            var
                lrecSalesInvLine: Record "Sales Invoice Line";
                lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
            begin
                if "Applies-To Source Line No." <> 0 then begin
                    if "Applies-To Source Type" = "Applies-To Source Type"::Customer then
                        FieldError("Applies-To Source Type");

                    TestField("Applies-To Source No.");

                    case "Applies-To Source Type" of
                        "Applies-To Source Type"::"Posted Sales Invoice":
                            begin
                                lrecSalesInvLine.Get("Applies-To Source No.", "Applies-To Source Line No.");
                            end;
                        "Applies-To Source Type"::"Posted Sales Cr. Memo":
                            begin
                                lrecSalesCrMemoLine.Get("Applies-To Source No.", "Applies-To Source Line No.");
                            end;
                    end;
                end;
            end;
        }
        field(25; "Rebate Code"; Code[20])
        {
            Caption = 'Rebate Code';
            TableRelation = IF ("Applies-To Source Type" = CONST("Posted Sales Invoice")) "Rebate Header ELA".Code
            ELSE
            IF ("Applies-To Source Type" = CONST("Posted Sales Cr. Memo")) "Rebate Header ELA".Code
            ELSE
            IF ("Applies-To Source Type" = CONST(Customer)) "Rebate Header ELA".Code
            ELSE
            IF ("Applies-To Source Type" = CONST("Posted Purch. Invoice")) "Purchase Rebate Header ELA".Code
            ELSE
            IF ("Applies-To Source Type" = CONST("Posted Purch. Cr. Memo")) "Purchase Rebate Header ELA".Code
            ELSE
            IF ("Applies-To Source Type" = CONST(Vendor)) "Purchase Rebate Header ELA".Code;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                GetRebateHeader;
                grecRebateHeader.TestField(Blocked, false);
                //</ENRE1.00>

                //<ENRE1.00>
                if CurrFieldNo = 0 then begin
                    if grecRebateHeader."Rebate Type" = grecRebateHeader."Rebate Type"::" " then begin
                        Error(Text000, grecRebateHeader."Rebate Type");
                    end;
                end;
                //</ENRE1.00>
            end;
        }
        field(26; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(50; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount ($)';
            DecimalPlaces = 2 : 2;
        }
        field(55; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(60; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(110; Adjustment; Boolean)
        {
            Description = 'ENRE1.00';
        }
    }

    keys
    {
        key(Key1; "Rebate Batch Name", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        RebateJnlBatch: Record "Rebate Batch ELA";
        RebateJnlLine: Record "Rebate Journal Line ELA";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        AXText001: Label '%1 cannot be %2 for %3 %4';
        grecRebateHeader: Record "Rebate Header ELA";
        Text000: Label 'Rebate Type %1 cannot be entered manually.';


    procedure SetUpNewLine(LastRebateJnlLine: Record "Rebate Journal Line ELA")
    begin
        RebateJnlBatch.Get("Rebate Batch Name");
        RebateJnlLine.SetRange("Rebate Batch Name", "Rebate Batch Name");
        if RebateJnlLine.Find('-') then begin
            "Posting Date" := LastRebateJnlLine."Posting Date";
            "Document No." := LastRebateJnlLine."Document No.";
            "Document No." := IncStr("Document No.");
        end else begin
            "Posting Date" := WorkDate;
            if RebateJnlBatch."No. Series" <> '' then begin
                Clear(NoSeriesMgt);
                "Document No." := NoSeriesMgt.GetNextNo(RebateJnlBatch."No. Series", "Posting Date", false);
            end;
        end;
        "Posting No. Series" := RebateJnlBatch."Posting No. Series";
    end;


    procedure EmptyLine(): Boolean
    begin
        exit(("Rebate Code" = '') and ("Amount (LCY)" = 0));
    end;


    procedure GetRebateHeader()
    begin
        //<ENRE1.00>
        if grecRebateHeader.Code <> "Rebate Code" then
            if grecRebateHeader.Get("Rebate Code") then;
        //</ENRE1.00>
    end;
}

