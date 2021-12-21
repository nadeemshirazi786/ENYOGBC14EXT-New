codeunit 14228811 "Granule License Management"
{
    // Copyright Axentia Solutions Corp.  1999-2011.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF13721AC 20110812 - jfIsLogisticsLicensed


    trigger OnRun()
    begin
    end;

    var
        grecLicensePermission: Record "License Permission";

    [Scope('Internal')]
    procedure jfTestTableLicensed(pintTable: Integer) pbln: Boolean
    begin
        //-- This function determines if a table has been licensed to avoid permission errors
        IF grecLicensePermission.GET(grecLicensePermission."Object Type"::Table, pintTable) THEN
            EXIT(grecLicensePermission."Execute Permission" = 1);

        EXIT(FALSE)
    end;

}