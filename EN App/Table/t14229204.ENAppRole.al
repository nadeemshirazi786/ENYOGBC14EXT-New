//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Mobile App Role (ID 14229204).
/// </summary>
table 14229204 "App. Role ELA"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;
    fields
    {
        field(10; "Role Code"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(20; "Role Name"; Text[30])
        {
            DataClassification = ToBeClassified;
        }

        field(30; "Role Type"; Option)
        {
            OptionMembers = " ",Picker,Production,Putaway,Receive,Replenish,Label,Iventory,Loader,,,,,,,Custom;
        }

        field(40; "Location Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }

        field(50; "Auto Assign Jobs"; Boolean)
        {

        }

        field(60; "Custom Role Filter"; Code[80])
        {

        }

        field(100; "App. Code"; Code[10])
        {
            TableRelation = "Application ELA" where(Enabled = filter(true));
        }
    }

    keys
    {
        key(PK; "Role Code")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    /// <summary>
    /// GetRole.
    /// </summary>
    /// <param name="RoleType">Text[30].</param>
    /// <param name="LocCode">Code[20].</param>
    /// <returns>Return value of type Code[20].</returns>
    procedure GetRole(RoleType: Text[30]; LocCode: Code[20]): Code[20]
    var
        AppRole: Record "App. Role ELA";
    begin

        AppRole.RESET;
        AppRole.SETRANGE("Location Code", LocCode);
        CASE RoleType OF
            'Picker':
                AppRole.SETRANGE("Role Type", AppRole."Role Type"::Picker);
            'Production':
                AppRole.SETRANGE("Role Type", AppRole."Role Type"::Production);
            'Putaway':
                AppRole.SETRANGE("Role Type", AppRole."Role Type"::Putaway);
            'Receive':
                AppRole.SETRANGE("Role Type", AppRole."Role Type"::Receive);
            'Replenish':
                AppRole.SETRANGE("Role Type", AppRole."Role Type"::Replenish);
            // 'CaseLabel':
            //     AppRole.SETRANGE("Role Type", AppRole."Role Type"::CaseLabel);
            ELSE
                AppRole.SETRANGE("Role Type", AppRole."Role Type"::Custom);
        END;

        IF AppRole.FINDFIRST THEN
            IF AppRole."Role Type" = AppRole."Role Type"::Custom THEN
                EXIT('')
            ELSE
                EXIT(AppRole."Role Code");
    end;


    /// <summary>
    /// GetRoleFilter.
    /// </summary>
    /// <param name="RoleCode">Text[30].</param>
    /// <param name="VAR DoAutoAssign">Boolean.</param>
    /// <param name="VAR RoleCodeFilter">Text[255].</param>
    procedure GetRoleFilter(RoleCode: Text[30]; VAR DoAutoAssign: Boolean; VAR RoleCodeFilter: Text[255])
    var
        AppRole: Record "App. Role ELA";
    begin
        AppRole.RESET;
        AppRole.SETRANGE(AppRole."Role Code", RoleCode);
        IF AppRole.FINDFIRST THEN
            IF AppRole."Role Type" = AppRole."Role Type"::Custom THEN BEGIN
                RoleCodeFilter := AppRole."Custom Role Filter";
                DoAutoAssign := AppRole."Auto Assign Jobs";
            END ELSE BEGIN
                RoleCodeFilter := AppRole."Role Code";
                DoAutoAssign := AppRole."Auto Assign Jobs";
            END;
    end;

}