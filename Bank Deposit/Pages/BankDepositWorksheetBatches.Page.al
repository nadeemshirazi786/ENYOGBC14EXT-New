page 14228824 "Bank Deposit Wksht Batches ELA"
{
    PageType = List;
    SourceTable = "Bank Deposit Wksht Batch ELA";
    UsageCategory = Administration;
    ApplicationArea = all;
    Caption = 'Bank Deposit Worksheet Batches';
    layout
    {
        area(content)
        {
            repeater(Control1102631000)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                }
                field(Description; Description)
                {
                }
                field("Bank Account No."; "Bank Account No.")
                {
                }
                field("Deposit Template Name"; "Deposit Template Name")
                {
                }
                field("Deposit Batch Name"; "Deposit Batch Name")
                {
                }
                field("EDI Trade Partner"; "EDI Trade Partner")
                {
                }
            }
        }
    }

    actions
    {
    }
}

