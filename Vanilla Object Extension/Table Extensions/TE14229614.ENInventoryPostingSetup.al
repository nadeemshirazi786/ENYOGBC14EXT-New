tableextension 14229614 "EN Inventory Posting Setup ELA" extends "Inventory Posting Setup"
{
    fields
    {
        field(14229100; "Writeoff Account (Company) ELA"; Code[20])
        {

            Caption = 'Writeoff Account (Company)';
            Description = 'PR3.61.01';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin

                GLAccountCategoryMgt.LookupGLAccount(
                  "Writeoff Account (Company) ELA", GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetInventory);
            end;

            trigger OnValidate()
            begin

                GLAccountCategoryMgt.CheckGLAccount(
                  "Writeoff Account (Company) ELA", false, false, GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetInventory);
            end;
        }
        field(14229101; "Writeoff Account (Vendor) ELA"; Code[20])
        {
            Caption = 'Writeoff Account (Vendor)';
            Description = 'PR3.61.01';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin

                GLAccountCategoryMgt.LookupGLAccount(
                  "Writeoff Account (Vendor) ELA", GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetInventory);
            end;

            trigger OnValidate()
            begin

                GLAccountCategoryMgt.CheckGLAccount(
                  "Writeoff Account (Vendor) ELA", false, false, GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetInventory);
            end;
        }

    }
    procedure GetWriteoffAccountCompanyELA(): Code[20]
    begin

        if "Writeoff Account (Company) ELA" = '' then
            PostingSetupMgt.SendInvtPostingSetupNotification(Rec, FieldCaption("Writeoff Account (Company) ELA"));
        TestField("Writeoff Account (Company) ELA");
        exit("Writeoff Account (Company) ELA");

    end;

    procedure GetWriteoffAccountVendorELA(): Code[20]
    begin


        if "Writeoff Account (Vendor) ELA" = '' then
            PostingSetupMgt.SendInvtPostingSetupNotification(Rec, FieldCaption("Writeoff Account (Vendor) ELA"));
        TestField("Writeoff Account (Vendor) ELA");
        exit("Writeoff Account (Vendor) ELA");

    end;

    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        YouCannotDeleteErr: Label 'You cannot delete %1 %2.', Comment = '%1 = Location Code; %2 = Posting Group';
        PostingSetupMgt: Codeunit PostingSetupManagement;
}
