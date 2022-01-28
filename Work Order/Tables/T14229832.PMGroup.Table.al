table 14229832 "PM Group ELA"
{
    DrillDownPageID = "PM Groups ELA";
    LookupPageID = "PM Groups ELA";

    fields
    {
        field(1; "Code"; Code[10])
        {
        }
        field(2; Description; Text[50])
        {
        }
        field(100; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(101; "Person Responsible Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            TableRelation = Employee;
        }
        field(102; "PM Type Filter"; Option)
        {
            FieldClass = FlowFilter;
            OptionCaption = ' ,Machine Center,Work Center,Fixed Asset';
            OptionMembers = " ","Machine Center","Work Center","Fixed Asset";
        }
        field(103; "PM No. Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            TableRelation = IF ("PM Type Filter" = CONST ("Machine Center")) "Machine Center"
            ELSE
            IF ("PM Type Filter" = CONST ("Work Center")) "Work Center"
            ELSE
            IF ("PM Type Filter" = CONST ("Fixed Asset")) "Fixed Asset";
        }
        field(104; "QA Document No. Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            TableRelation = IF ("QA Doc. Type Filter" = CONST ("Purch. Receipt")) "Purch. Rcpt. Header"
            ELSE
            IF ("QA Doc. Type Filter" = CONST ("Production Order")) "Production Order" WHERE (Status = FILTER (Released | Finished))
            ELSE
            IF ("QA Doc. Type Filter" = CONST ("Sales Return")) "Sales Header" WHERE ("Document Type" = CONST ("Return Order"))
            ELSE
            IF ("QA Doc. Type Filter" = CONST ("Sales Credit")) "Sales Header" WHERE ("Document Type" = CONST ("Credit Memo"));
        }
        field(105; "QA Doc. Type Filter"; Option)
        {
            FieldClass = FlowFilter;
            OptionCaption = ' ,Purch. Receipt,Production Order,Sales Return,Sales Credit';
            OptionMembers = " ","Purch. Receipt","Production Order","Sales Return","Sales Credit";
        }
        field(106; "PM Procedure Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            //TableRelation = Table23019200.Field1;
        }
        field(107; "PM Failure Filter"; Boolean)
        {
            FieldClass = FlowFilter;
        }
        field(108; "Test Complete Filter"; Boolean)
        {
            FieldClass = FlowFilter;
        }
        field(120; "PM Work Order Count"; Integer)
        {
            CalcFormula = Count ("Work Order Header ELA" WHERE ("PM Group Code" = FIELD (Code),
                                                     "Person Responsible" = FIELD ("Person Responsible Filter"),
                                                     "Work Order Date" = FIELD ("Date Filter"),
                                                     Type = FIELD ("PM Type Filter"),
                                                     "No." = FIELD ("PM No. Filter"),
                                                     "PM Procedure Code" = FIELD ("PM Procedure Filter"),
                                                     "PM WO Failure" = FIELD ("PM Failure Filter"),
                                                     "Test Complete" = FIELD ("Test Complete Filter")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(121; "PM Procedure Count"; Integer)
        {
            CalcFormula = Count ("PM Procedure Header ELA" WHERE ("PM Group Code" = FIELD (Code)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(122; "Fin. PMWO Count"; Integer)
        {
            CalcFormula = Count ("Finished WO Header ELA" WHERE ("PM Group Code" = FIELD (Code)));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

