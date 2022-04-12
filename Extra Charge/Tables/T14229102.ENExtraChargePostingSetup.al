table 14229102 "EN Extra Charge Posting Setup"
{

    Caption = 'Extra Charge Posting Setup';

    fields
    {
        field(1; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(2; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            NotBlank = true;
            TableRelation = "Gen. Product Posting Group";
        }
        field(3; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
            NotBlank = true;
            TableRelation = "EN Extra Charge";
        }
        field(14; "Direct Cost Applied Account"; Code[20])
        {
            Caption = 'Direct Cost Applied Account';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Direct Cost Applied Account");
            end;
        }
        field(15; "Invt. Accrual Acc. (Interim)"; Code[20])
        {
            Caption = 'Invt. Accrual Acc. (Interim)';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Invt. Accrual Acc. (Interim)");
            end;
        }
    }

    keys
    {
        key(Key1; "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Extra Charge Code")
        {
            Clustered = true;
        }
        key(Key2; "Extra Charge Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PostingSetupMgt: Codeunit ENPostingSetupManagement;

    local procedure CheckGLAcc(AccNo: Code[20])
    var
        GLAcc: Record "G/L Account";
    begin
        if AccNo <> '' then begin
            GLAcc.Get(AccNo);
            GLAcc.CheckGLAcc;
        end;
    end;

    procedure GetDirectCostAppliedAccount(): Code[20]
    begin

        if "Direct Cost Applied Account" = '' then
            PostingSetupMgt.SendECPostingSetupNotification(Rec, FieldCaption("Direct Cost Applied Account"));
        TestField("Direct Cost Applied Account");
        exit("Direct Cost Applied Account");
    end;

    procedure GetInventoryAccrualAccount(): Code[20]
    begin

        if "Invt. Accrual Acc. (Interim)" = '' then
            PostingSetupMgt.SendECPostingSetupNotification(Rec, FieldCaption("Invt. Accrual Acc. (Interim)"));
        TestField("Invt. Accrual Acc. (Interim)");
        exit("Invt. Accrual Acc. (Interim)");
    end;
}

