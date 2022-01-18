table 23019287 "PM Group"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JFMG
    //   20080925 - fix calcformula for 'PM Procedure Count' and 'Fin. PMWO Count'

    DrillDownPageID = 23019291;
    LookupPageID = 23019291;

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
            TableRelation = Table23019200.Field1;
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
            CalcFormula = Count (Table23019260 WHERE (Field11 = FIELD (Code),
                                                     Field10 = FIELD ("Person Responsible Filter"),
                                                     Field100 = FIELD ("Date Filter"),
                                                     Field20 = FIELD ("PM Type Filter"),
                                                     Field101 = FIELD ("PM No. Filter"),
                                                     Field3 = FIELD ("PM Procedure Filter"),
                                                     Field201 = FIELD ("PM Failure Filter"),
                                                     Field202 = FIELD ("Test Complete Filter")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(121; "PM Procedure Count"; Integer)
        {
            CalcFormula = Count ("PM Procedure Header" WHERE ("PM Group Code" = FIELD (Code)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(122; "Fin. PMWO Count"; Integer)
        {
            CalcFormula = Count (Table23019270 WHERE (Field11 = FIELD (Code)));
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

