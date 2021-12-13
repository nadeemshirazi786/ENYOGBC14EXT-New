table 14228821 "Global Group ELA"
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
    //   20111014 - code to OnDelete for Inventory Setup
    // 
    // JF14949SHR
    //   20111014 - code to OnDelete for Purchases & Payables Setup

    DataCaptionFields = "Code", Description;
    DrillDownPageID = "Global Groups ELA";
    LookupPageID = "Global Groups ELA";

    fields
    {
        field(1; "Code"; Code[20])
        {
            NotBlank = true;
            Caption = 'Code';
            trigger OnValidate()
            begin
                UpdateText(Code, '', Description);
                UpdateText(Code, Text008, "Code Caption");
                UpdateText(Code, Text009, "Filter Caption");
            end;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "Code Caption"; Text[30])
        {
            Caption = 'Code Caption';
        }
        field(4; "Filter Caption"; Text[30])
        {
            Caption = 'Filter Caption';
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

    trigger OnDelete()
    begin
        grecGlobalGroupValue.SETRANGE("Master Group", Code);
        grecGlobalGroupValue.DELETEALL(TRUE);

        grecSRSetup.GET;
        CASE Code OF
            grecSRSetup."Global Group 1 Code ELA":
                BEGIN
                    grecSRSetup."Global Group 1 Code ELA" := '';
                    grecSRSetup.MODIFY;
                END;
            grecSRSetup."Global Group 2 Code ELA":
                BEGIN
                    grecSRSetup."Global Group 2 Code ELA" := '';
                    grecSRSetup.MODIFY;
                END;
            grecSRSetup."Global Group 3 Code ELA":
                BEGIN
                    grecSRSetup."Global Group 3 Code ELA" := '';
                    grecSRSetup.MODIFY;
                END;
            grecSRSetup."Global Group 4 Code ELA":
                BEGIN
                    grecSRSetup."Global Group 4 Code ELA" := '';
                    grecSRSetup.MODIFY;
                END;
            grecSRSetup."Global Group 5 Code ELA":
                BEGIN
                    grecSRSetup."Global Group 5 Code ELA" := '';
                    grecSRSetup.MODIFY;
                END;
        END;

        //<JF14949SHR>
        grecInvtSetup.GET;
        CASE Code OF
            grecInvtSetup."Global Group 1 Code ELA":
                BEGIN
                    grecInvtSetup."Global Group 1 Code ELA" := '';
                    grecInvtSetup.MODIFY;
                END;
            grecInvtSetup."Global Group 2 Code ELA":
                BEGIN
                    grecInvtSetup."Global Group 2 Code ELA" := '';
                    grecInvtSetup.MODIFY;
                END;
            grecInvtSetup."Global Group 3 Code ELA":
                BEGIN
                    grecInvtSetup."Global Group 3 Code ELA" := '';
                    grecInvtSetup.MODIFY;
                END;
            grecInvtSetup."Global Group 4 Code ELA":
                BEGIN
                    grecInvtSetup."Global Group 4 Code ELA" := '';
                    grecInvtSetup.MODIFY;
                END;
            grecInvtSetup."Global Group 5 Code ELA":
                BEGIN
                    grecInvtSetup."Global Group 5 Code ELA" := '';
                    grecInvtSetup.MODIFY;
                END;
        END;
        //     //</JF14949SHR>

        //     //<JF14991SHR>
        grecPPSetup.GET;
        CASE Code OF
            grecPPSetup."Global Group 1 Code ELA":
                BEGIN
                    grecPPSetup."Global Group 1 Code ELA" := '';
                    grecPPSetup.MODIFY;
                END;
            grecPPSetup."Global Group 2 Code ELA":
                BEGIN
                    grecPPSetup."Global Group 2 Code ELA" := '';
                    grecPPSetup.MODIFY;
                END;
            grecPPSetup."Global Group 3 Code ELA":
                BEGIN
                    grecPPSetup."Global Group 3 Code ELA" := '';
                    grecPPSetup.MODIFY;
                END;
            grecPPSetup."Global Group 4 Code ELA":
                BEGIN
                    grecPPSetup."Global Group 4 Code ELA" := '';
                    grecPPSetup.MODIFY;
                END;
            grecPPSetup."Global Group 5 Code ELA":
                BEGIN
                    grecPPSetup."Global Group 5 Code ELA" := '';
                    grecPPSetup.MODIFY;
                END;
        END;
        //     //</JF14991SHR>
    end;

    var
        Text008: Label 'Code';
        Text009: Label 'Filter';
        grecGlobalGroupValue: Record "Global Group Value ELA";
        grecSRSetup: Record "Sales & Receivables Setup";
        grecInvtSetup: Record "Inventory Setup";
        grecPPSetup: Record "Purchases & Payables Setup";
        grecCustomer: Record Customer;
        grecItem: Record Item;
        grecVendor: Record Vendor;

    [Scope('Internal')]
    procedure UpdateText("Code": Code[20]; AddText: Text[30]; var Text: Text[30])
    begin
        IF Text = '' THEN BEGIN
            Text := LOWERCASE(Code);
            Text[1] := Code[1];
            IF AddText <> '' THEN
                Text := STRSUBSTNO('%1 %2', Text, AddText);
        END;
    end;
}

