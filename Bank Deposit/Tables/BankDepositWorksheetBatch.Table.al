table 14228824 "Bank Deposit Wksht Batch ELA"
{
    DrillDownPageID = "Bank Deposit Wksht Batches ELA";
    LookupPageID = "Bank Deposit Wksht Batches ELA";

    fields
    {
        field(10; Name; Code[10])
        {
        }
        field(20; Description; Text[50])
        {
        }
        field(30; "Bank Account No."; Code[20])
        {
            TableRelation = "Bank Account"."No.";
        }
        field(40; "EDI Trade Partner"; Code[20])
        {
            //TableRelation = Table14002360.Field1;

            trigger OnValidate()
            var
                lrecBankDepBatch: Record "Bank Deposit Wksht Batch ELA";
            begin
                //-- Only one batch per EDI Trade Partner
                // if "EDI Trade Partner" <> '' then begin
                //     lrecBankDepBatch.SetCurrentKey("EDI Trade Partner");

                //     lrecBankDepBatch.SetRange("EDI Trade Partner", "EDI Trade Partner");
                //     lrecBankDepBatch.SetFilter(Name, '<>%1', Name);

                //     if lrecBankDepBatch.FindFirst then
                //         Error(gjfText000, "EDI Trade Partner", TableCaption);
                // end;
            end;
        }
        field(50; "Deposit Template Name"; Code[10])
        {
            TableRelation = "Gen. Journal Template".Name WHERE (Type = CONST (Deposits));
        }
        field(60; "Deposit Batch Name"; Code[10])
        {
            TableRelation = "Gen. Journal Batch".Name WHERE ("Journal Template Name" = FIELD ("Deposit Template Name"));
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
        key(Key2; "EDI Trade Partner")
        {
            MaintainSIFTIndex = false;
        }
    }

    fieldgroups
    {
    }

    var
        gjfText000: Label 'EDI Trade Partner %1 can only be assigned to one %2';
}

