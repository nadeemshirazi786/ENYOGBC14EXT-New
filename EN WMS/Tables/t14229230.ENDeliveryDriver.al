//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Delivery Driver (ID 14229230).
/// </summary>
table 14229230 "Delivery Driver ELA"
{
    Caption = 'Delivery Driver';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(3; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = ToBeClassified;
        }
        field(4; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = ToBeClassified;
        }
        field(5; City; Text[30])
        {
            Caption = 'City';
            TableRelation =
                if ("Country/Region Code" = const()) "Post Code".City
            else
            if ("Country/Region Code" = Filter(<> '')) "Post Code".City
            where("Country/Region Code" = field("Country/Region Code"));
            DataClassification = ToBeClassified;
        }
        field(8; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = ToBeClassified;
        }
        field(6; State; Text[30])
        {
            Caption = 'State';
            CaptionClass = '5,1,' + "Country/Region Code";
            DataClassification = ToBeClassified;
        }
        //todo
        field(7; "Zip Code"; Code[20])
        {
            Caption = 'Zip Code';
            TableRelation = if ("Country/Region Code" = const()) "Post Code" else
            if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;
            DataClassification = ToBeClassified;
        }
        field(9; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
            // DataClassification = tobeclas
        }

        //todo test
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

}
