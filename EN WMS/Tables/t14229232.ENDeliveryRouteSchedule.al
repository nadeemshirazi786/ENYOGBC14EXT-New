//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Delivery Route Schedule (ID 14229232).
/// </summary>
table 14229232 "Delivery Route Schedule ELA"
{
    Caption = 'Delivery Route Schedule';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            TableRelation = "Delivery Route ELA";
            DataClassification = ToBeClassified;
        }

        field(2; Day; Option)
        {
            Caption = 'Day';
            OptionMembers = ,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday;
            DataClassification = ToBeClassified;
        }
        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Delivery Route No.")
        {
            Clustered = true;
        }
    }

}
