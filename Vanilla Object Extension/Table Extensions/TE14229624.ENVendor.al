tableextension 14229624 "EN LT Vendor EXT ELA" extends Vendor
{


    fields
    {
        field(14229000; "Vendor Price Group ELA"; Code[20])
        {
            Caption = 'Vendor Price Group';
            DataClassification = ToBeClassified;
            TableRelation = "EN Vendor Price Group";
        }
        field(14229001; "Purch. Price/Sur. Dt Cntrl ELA"; Enum "EN Purch. Price/Sur. Dt Cntrl")
        {
            Caption = 'Purch. Price/Sur. Date Control';
            DataClassification = ToBeClassified;
        }
        field(14229400; "Rebate Group Code ELA"; Code[20])
        {
            Caption = 'Rebate Group Code';
            DataClassification = ToBeClassified;
            TableRelation = "Rebate Group ELA";
        }
        field(14229401; "Vendor Buying Group Code ELA"; Code[20])
        {
            Caption = 'Vendor Buying Group Code';
            DataClassification = ToBeClassified;
            TableRelation = "Vendor Buying Group ELA".Code;
        }
        field(14229402; "Rebate Code Filter ELA"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Rebate Code Filter';
            TableRelation = "Rebate Header ELA";

        }
        field(14229150; "Commodity Vendor Type ELA"; Option)
        {
            Caption = 'ELA Commodity Vendor Type';
            DataClassification = ToBeClassified;
            OptionMembers = ,Producer,Hauler,Broker;
        }
        field(14229151; "Shelf Life Requirement"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(51000; "Purchase Price Unit of Measure"; Code[10])
        {
            TableRelation = "Unit of Measure".Code;
            DataClassification = ToBeClassified;
        }
        field(51002; "Global Group 1 Code ELA"; Code[20])
        {
            Caption = 'Global Group 1 Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                PurchSetup: Record "Purchases & Payables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 1 Code ELA" <> '' THEN BEGIN
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Global Group 1 Code ELA");
                    GlobalGroupValue.GET(PurchSetup."Global Group 1 Code ELA", "Global Group 1 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                PurchSetup: Record "Purchases & Payables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
                GlobalGroupValues: Page "Global Group Values ELA";
            begin

                CLEAR(GlobalGroupValues);
                PurchSetup.GET;
                PurchSetup.TESTFIELD("Global Group 1 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', PurchSetup."Global Group 1 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 1 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }
        field(51003; "Global Group 2 Code ELA"; Code[20])
        {
            Caption = 'Global Group 2 Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                PurchSetup: Record "Purchases & Payables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 2 Code ELA" <> '' THEN BEGIN
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Global Group 2 Code ELA");
                    GlobalGroupValue.GET(PurchSetup."Global Group 2 Code ELA", "Global Group 2 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                PurchSetup: Record "Purchases & Payables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
                GlobalGroupValues: Page "Global Group Values ELA";
            begin
                CLEAR(GlobalGroupValues);
                PurchSetup.GET;
                PurchSetup.TESTFIELD("Global Group 2 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', PurchSetup."Global Group 2 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 2 Code ELA" := GlobalGroupValue.Code;
                END;
            end;

        }
        field(51004; "Global Group 3 Code ELA"; Code[20])
        {
            Caption = 'Global Group 3 Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                PurchSetup: Record "Purchases & Payables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 3 Code ELA" <> '' THEN BEGIN
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Global Group 3 Code ELA");
                    GlobalGroupValue.GET(PurchSetup."Global Group 3 Code ELA", "Global Group 3 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                PurchSetup: Record "Purchases & Payables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
                GlobalGroupValues: Page "Global Group Values ELA";
            begin
                CLEAR(GlobalGroupValues);
                PurchSetup.GET;
                PurchSetup.TESTFIELD("Global Group 3 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', PurchSetup."Global Group 3 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 3 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }
        field(51005; "Global Group 4 Code ELA"; Code[20])
        {
            Caption = 'Global Group 4 Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                PurchSetup: Record "Purchases & Payables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 4 Code ELA" <> '' THEN BEGIN
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Global Group 4 Code ELA");
                    GlobalGroupValue.GET(PurchSetup."Global Group 4 Code ELA", "Global Group 4 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                PurchSetup: Record "Purchases & Payables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
                GlobalGroupValues: Page "Global Group Values ELA";
            begin
                CLEAR(GlobalGroupValues);
                PurchSetup.GET;
                PurchSetup.TESTFIELD("Global Group 4 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', PurchSetup."Global Group 4 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 4 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }
        field(51006; "Global Group 5 Code ELA"; Code[20])
        {
            Caption = 'Global Group 5 Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                PurchSetup: Record "Purchases & Payables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 5 Code ELA" <> '' THEN BEGIN
                    PurchSetup.GET;
                    PurchSetup.TESTFIELD("Global Group 5 Code ELA");
                    GlobalGroupValue.GET(PurchSetup."Global Group 5 Code ELA", "Global Group 5 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                PurchSetup: Record "Purchases & Payables Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
                GlobalGroupValues: Page "Global Group Values ELA";
            begin
                CLEAR(GlobalGroupValues);
                PurchSetup.GET;
                PurchSetup.TESTFIELD("Global Group 5 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', PurchSetup."Global Group 5 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 5 Code ELA" := GlobalGroupValue.Code;
                END;
            end;

        }
        field(51007; "Use Over-Rece. Tolerance ELA"; boolean)
        {
            Caption = 'Use Over-Receiving Tolerance';
        }
        field(51008; "Over-Receiving Tolerance % ELA"; Decimal)
        {
            Caption = 'Over-Receiving Tolerance %';
        }
        field(51009; "Broker Contact No. ELA"; Code[20])
        {
            Caption = 'Broker Contact No.';
            DataClassification = ToBeClassified;
            TableRelation = Contact."No.";
            trigger OnValidate()
            begin

                IF grecContact.GET("Broker Contact No. ELA") THEN BEGIN
                    "Broker Contact Name ELA" := grecContact.Name;
                    "Broker Phone No. ELA" := grecContact."Phone No.";
                END;
            end;
        }
        field(51010; "Broker Contact Name ELA"; Text[50])
        {
            Caption = 'Broker Contact Name';
            DataClassification = ToBeClassified;
        }
        field(51011; "Broker Phone No. ELA"; Text[30])
        {
            Caption = 'Broker Phone No.';
            ExtendedDatatype = PhoneNo;
            DataClassification = ToBeClassified;
        }
        field(51012; "Communication group code ELA"; Code[20])
        {
            Caption = 'Communication group code';
            TableRelation = "Communication Group ELA".Code;
            DataClassification = ToBeClassified;
        }
        field(51013; "Shipping Instructions ELA"; Text[50])
        {
            Caption = 'Shipping Instructions';
            DataClassification = ToBeClassified;
        }
    }
    var
        grecContact: Record Contact;
}