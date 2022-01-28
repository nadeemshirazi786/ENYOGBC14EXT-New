//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Mobile App. User (ID 14229202).
/// </summary>
table 14229202 "Application User ELA"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;
    fields
    {
        field(10; "App. Code"; Code[10])
        {
            TableRelation = "Application ELA";
        }

        field(20; "User ID"; Code[10])
        {
            DataClassification = ToBeClassified;
        }

        field(30; "PIN Code"; Code[4])
        {

        }

        field(40; "Is Admin"; Boolean)
        {

        }

        field(50; "Default Location"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }

        field(60; "Default Role"; Code[10])
        {
            TableRelation = "App. Role ELA";

            trigger OnValidate()
            begin
                IF NOT "Use only Default Role" THEN
                    ERROR(TEXT14229200);
            end;
        }

        field(70; "Use only Default Role"; Boolean)
        {
            trigger OnValidate()
            begin
                IF NOT "Use only Default Role" THEN
                    "Default Role" := '';
            end;
        }

        field(80; "Blocked"; Boolean)
        {
        }

        field(90; "DSD Route No."; Code[10])
        {

        }

        field(100; "DSD Responsibility Center"; Code[10])
        {

        }

        field(110; "DSD Load Order Prefix"; COde[6])
        {

        }

        field(120; "DSD Transaction Prefix"; Code[6])
        {

        }

        field(130; "Default Company"; Code[20])
        {
            TableRelation = Company;
        }

    }

    keys
    {
        key(PK; "App. Code", "User ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ValidateAppUserPermission;
    end;

    trigger OnModify()
    begin
        ValidateAppUserPermission;
    end;

    trigger OnDelete()
    begin
        ValidateAppUserPermission;
    end;

    trigger OnRename()
    begin
        ValidateAppUserPermission;
    end;

    local procedure ValidateAppUserPermission()
    var
        UserSetup: Record "User Setup";
    begin

        IF NOT UserSetup.GET(USERID) THEN begin
            UserSetup.INIT;
        end;


        IF NOT UserSetup."Can Modify App. Users ELA" THEN
            ERROR(STRSUBSTNO(TEXT14229201, USERID));
    end;

    var
        TEXT14229201: TextConst ENU = 'User %1 is not permitted to make any changes to WMS Users';
        TEXT14229200: TextConst ENU = 'Cannot assigned role';
}