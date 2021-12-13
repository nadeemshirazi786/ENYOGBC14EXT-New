table 14228822 "Global Group Value ELA"
{
    // Copyright Axentia Solutions Corp.  1999-2011.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF14955SHR
    //   20111012 - new table
    // 
    // JF14949SHR
    //   20111014 - code to OnRename for Inventory Setup
    // 
    // JF14949SHR
    //   20111014 - code to OnRename for Purchases & Payables Setup

    LookupPageID = "Global Group Values ELA";

    fields
    {
        field(1; "Master Group"; Code[20])
        {
            NotBlank = true;
            TableRelation = "Global Group ELA";

        }
        field(2; "Code"; Code[20])
        {
            NotBlank = true;
            Caption = 'Code';
        }
        field(3; Name; Text[50])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1; "Master Group", "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        grecSRSetup.GET;
        CASE "Master Group" OF
            grecSRSetup."Global Group 1 Code ELA":
                BEGIN
                    grecCustomer.SETRANGE("Global Group 1 Code ELA", Code);
                    IF NOT grecCustomer.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecCustomer.TABLECAPTION);
                END;
            grecSRSetup."Global Group 2 Code ELA":
                BEGIN
                    grecCustomer.SETRANGE("Global Group 2 Code ELA", Code);
                    IF NOT grecCustomer.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecCustomer.TABLECAPTION);
                END;
            grecSRSetup."Global Group 3 Code ELA":
                BEGIN
                    grecCustomer.SETRANGE("Global Group 3 Code ELA", Code);
                    IF NOT grecCustomer.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecCustomer.TABLECAPTION);
                END;
            grecSRSetup."Global Group 4 Code ELA":
                BEGIN
                    grecCustomer.SETRANGE("Global Group 4 Code ELA", Code);
                    IF NOT grecCustomer.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecCustomer.TABLECAPTION);
                END;
            grecSRSetup."Global Group 5 Code ELA":
                BEGIN
                    grecCustomer.SETRANGE("Global Group 5 Code ELA", Code);
                    IF NOT grecCustomer.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecCustomer.TABLECAPTION);
                END;
        END;

        //<JF14949SHR>
        grecInvtSetup.GET;
        CASE "Master Group" OF
            grecInvtSetup."Global Group 1 Code ELA":
                BEGIN
                    grecItem.SETRANGE("Global Group 1 Code ELA", Code);
                    IF NOT grecItem.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecItem.TABLECAPTION);
                END;
            grecInvtSetup."Global Group 2 Code ELA":
                BEGIN
                    grecItem.SETRANGE("Global Group 2 Code ELA", Code);
                    IF NOT grecItem.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecItem.TABLECAPTION);
                END;
            grecInvtSetup."Global Group 3 Code ELA":
                BEGIN
                    grecItem.SETRANGE("Global Group 3 Code ELA", Code);
                    IF NOT grecItem.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecItem.TABLECAPTION);
                END;
            grecInvtSetup."Global Group 4 Code ELA":
                BEGIN
                    grecItem.SETRANGE("Global Group 4 Code ELA", Code);
                    IF NOT grecItem.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecItem.TABLECAPTION);
                END;
            grecInvtSetup."Global Group 5 Code ELA":
                BEGIN
                    grecItem.SETRANGE("Global Group 5 Code ELA", Code);
                    IF NOT grecItem.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecItem.TABLECAPTION);
                END;
        END;
        //</JF14949SHR>

        //<JF14991SHR>
        grecPPSetup.GET;
        CASE "Master Group" OF
            grecPPSetup."Global Group 1 Code ELA":
                BEGIN
                    grecVendor.SETRANGE("Global Group 1 Code ELA", Code);
                    IF NOT grecVendor.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecVendor.TABLECAPTION);
                END;
            grecPPSetup."Global Group 2 Code ELA":
                BEGIN
                    grecVendor.SETRANGE("Global Group 2 Code ELA", Code);
                    IF NOT grecVendor.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecVendor.TABLECAPTION);
                END;
            grecPPSetup."Global Group 3 Code ELA":
                BEGIN
                    grecVendor.SETRANGE("Global Group 3 Code ELA", Code);
                    IF NOT grecVendor.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecVendor.TABLECAPTION);
                END;
            grecPPSetup."Global Group 4 Code ELA":
                BEGIN
                    grecVendor.SETRANGE("Global Group 4 Code ELA", Code);
                    IF NOT grecVendor.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecVendor.TABLECAPTION);
                END;
            grecPPSetup."Global Group 5 Code ELA":
                BEGIN
                    grecVendor.SETRANGE("Global Group 5 Code ELA", Code);
                    IF NOT grecVendor.ISEMPTY THEN
                        ERROR(gtxt000, Code, grecVendor.TABLECAPTION);
                END;
        END;
        //</JF14991SHR>
    end;

    trigger OnRename()
    begin
        grecSRSetup.GET;
        CASE "Master Group" OF
            grecSRSetup."Global Group 1 Code ELA":
                BEGIN
                    grecCustomer.SETRANGE("Global Group 1 Code ELA", xRec.Code);
                    grecCustomer.MODIFYALL("Global Group 1 Code ELA", Code);
                END;
            grecSRSetup."Global Group 2 Code ELA":
                BEGIN
                    grecCustomer.SETRANGE("Global Group 2 Code ELA", xRec.Code);
                    grecCustomer.MODIFYALL("Global Group 2 Code ELA", Code);
                END;
            grecSRSetup."Global Group 3 Code ELA":
                BEGIN
                    grecCustomer.SETRANGE("Global Group 3 Code ELA", xRec.Code);
                    grecCustomer.MODIFYALL("Global Group 3 Code ELA", Code);
                END;
            grecSRSetup."Global Group 4 Code ELA":
                BEGIN
                    grecCustomer.SETRANGE("Global Group 4 Code ELA", xRec.Code);
                    grecCustomer.MODIFYALL("Global Group 4 Code ELA", Code);
                END;
            grecSRSetup."Global Group 5 Code ELA":
                BEGIN
                    grecCustomer.SETRANGE("Global Group 5 Code ELA", xRec.Code);
                    grecCustomer.MODIFYALL("Global Group 5 Code ELA", Code);
                END;
        END;

        //<JF14949SHR>
        grecInvtSetup.GET;
        CASE "Master Group" OF
            grecInvtSetup."Global Group 1 Code ELA":
                BEGIN
                    grecItem.SETRANGE("Global Group 1 Code ELA", xRec.Code);
                    grecItem.MODIFYALL("Global Group 1 Code ELA", Code);
                END;
            grecInvtSetup."Global Group 2 Code ELA":
                BEGIN
                    grecItem.SETRANGE("Global Group 2 Code ELA", xRec.Code);
                    grecItem.MODIFYALL("Global Group 2 Code ELA", Code);
                END;
            grecInvtSetup."Global Group 3 Code ELA":
                BEGIN
                    grecItem.SETRANGE("Global Group 3 Code ELA", xRec.Code);
                    grecItem.MODIFYALL("Global Group 3 Code ELA", Code);
                END;
            grecInvtSetup."Global Group 4 Code ELA":
                BEGIN
                    grecItem.SETRANGE("Global Group 4 Code ELA", xRec.Code);
                    grecItem.MODIFYALL("Global Group 4 Code ELA", Code);
                END;
            grecInvtSetup."Global Group 5 Code ELA":
                BEGIN
                    grecItem.SETRANGE("Global Group 5 Code ELA", xRec.Code);
                    grecItem.MODIFYALL("Global Group 5 Code ELA", Code);
                END;
        END;
        //</JF14949SHR>

        //<JF14991SHR>
        grecPPSetup.GET;
        CASE "Master Group" OF
            grecPPSetup."Global Group 1 Code ELA":
                BEGIN
                    grecVendor.SETRANGE("Global Group 1 Code ELA", xRec.Code);
                    grecVendor.MODIFYALL("Global Group 1 Code ELA", Code);
                END;
            grecPPSetup."Global Group 2 Code ELA":
                BEGIN
                    grecVendor.SETRANGE("Global Group 2 Code ELA", xRec.Code);
                    grecVendor.MODIFYALL("Global Group 2 Code ELA", Code);
                END;
            grecPPSetup."Global Group 3 Code ELA":
                BEGIN
                    grecVendor.SETRANGE("Global Group 3 Code ELA", xRec.Code);
                    grecVendor.MODIFYALL("Global Group 3 Code ELA", Code);
                END;
            grecPPSetup."Global Group 4 Code ELA":
                BEGIN
                    grecVendor.SETRANGE("Global Group 4 Code ELA", xRec.Code);
                    grecVendor.MODIFYALL("Global Group 4 Code ELA", Code);
                END;
            grecPPSetup."Global Group 5 Code ELA":
                BEGIN
                    grecVendor.SETRANGE("Global Group 5 Code ELA", xRec.Code);
                    grecVendor.MODIFYALL("Global Group 5 Code ELA", Code);
                END;
        END;
        //</JF14991SHR>
    end;

    var
        grecSRSetup: Record "Sales & Receivables Setup";
        grecInvtSetup: Record "Inventory Setup";
        grecPPSetup: Record "Purchases & Payables Setup";
        grecCustomer: Record Customer;
        grecItem: Record Item;
        grecVendor: Record Vendor;
        gtxt000: Label 'Cannot delete the Global Group Value %1. You have entries in the %2 table assigned to this Global Group.';
}

