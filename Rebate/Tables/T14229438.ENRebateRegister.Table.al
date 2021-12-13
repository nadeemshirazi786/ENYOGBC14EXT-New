table 14229438 "Rebate Register ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //   2013015 - changed tablerelation of 6 from User to User."User Name"; changed ValidateTableRelation to No; added lookup and validate code

    Caption = 'Rebate Register';

    fields
    {
        field(1; "No."; Integer)
        {
            Caption = 'No.';
        }
        field(2; "From Entry No."; Integer)
        {
            Caption = 'From Entry No.';
            TableRelation = "Rebate Ledger Entry ELA";
        }
        field(3; "To Entry No."; Integer)
        {
            Caption = 'To Entry No.';
            TableRelation = "Rebate Ledger Entry ELA";
        }
        field(4; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
        }
        field(5; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(6; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                //<ENRE1.00>
                gcduUserMgt.LookupUserID("User ID");
                //</ENRE1.00>
            end;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                gcduUserMgt.ValidateUserID("User ID");
                //</ENRE1.00>
            end;
        }
        field(7; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Job Journal Batch";
            //This property is currently not supported
            //TestTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        gcduUserMgt: Codeunit "User Management";
}

