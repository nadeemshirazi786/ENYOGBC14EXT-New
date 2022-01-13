pageextension 14229400 "Vendor Card ELA" extends "Vendor Card"
{
    // ENRE1.00 2021-09-08 AJ
    layout
    {
        // Add changes to page layout here
        addlast("Posting Details")
        {
            field("Vendor Buying Group Code ELA"; "Vendor Buying Group Code ELA")
            {
                ApplicationArea = All;
            }
            field("Vendor Price Group ELA"; "Vendor Price Group ELA")
            {
                ApplicationArea = All;
            }
            field("Purch. Price/Sur. Dt Cntrl ELA"; "Purch. Price/Sur. Dt Cntrl ELA")
            {
                ApplicationArea = All;
            }
        }
        addlast("Foreign Trade")
        {


            field("Rebate Group Code"; "Rebate Group Code ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Rebate group that applies to the vendor. Used to group vendors together for the purpose of setting up rebates.';

                trigger OnValidate()
                begin
                    //ENRE1.00
                end;
            }
        }
        addlast("Address & Contact")
        {
            field("Broker Contact No."; "Broker Contact No. ELA")
            {
                ApplicationArea = All;
            }
            field("Broker Contact Name"; "Broker Contact Name ELA")
            {
                ApplicationArea = All;
            }
            field("Broker Phone No."; "Broker Phone No. ELA")
            {
                ApplicationArea = All;
            }
            field("Communication group code"; "Communication group code ELA")
            {
                ApplicationArea = All;
            }
        }
        addlast(Receiving)
        {
            field("Shipping Instructions"; "Shipping Instructions ELA")
            {
                ApplicationArea = All;
            }
        }

        addafter(Receiving)
        {
            group("Global Group ELA")
            {
                Caption = 'Global Group';
                field("Global Group 1 Code ELA"; "Global Group 1 Code ELA")
                {
                    Caption = 'Global Group 1 Code';
                }
                field("Global Group 2 Code ELA"; "Global Group 2 Code ELA")
                {
                    Caption = 'Global Group 2 Code';
                }
                field("Global Group 3 Code ELA"; "Global Group 3 Code ELA")
                {
                    Caption = 'Global Group 3 Code';
                }
                field("Global Group 4 Code ELA"; "Global Group 4 Code ELA")
                {
                    Caption = 'Global Group 4 Code';
                }
                field("Global Group 5 Code ELA"; "Global Group 5 Code ELA")
                {
                    Caption = 'Global Group 5 Code';
                }
            }

        }

    }

    actions
    {
        // Add changes to page actions here
    }
    procedure ActivateFields()
    var
        lintVendorApproval: Integer;
    begin

        ContactEditable := "Primary Contact No." = '';

        //<JF00043DO>
        "Broker Contact NameEditable" := "Broker Contact No. ELA" = '';
        "Broker Phone No.Editable" := "Broker Contact No. ELA" = '';
        //<JF00043DO>

        //<JF00088MG>
        // lintVendorApproval := jfCheckVendorApprovalReqd;

        "Approved 1Editable" := FALSE;
        "Approved 2Editable" := FALSE;

        IF lintVendorApproval > 0 THEN BEGIN
            "Approved 1Editable" := TRUE;
        END;

        IF lintVendorApproval > 1 THEN BEGIN
            "Approved 2Editable" := TRUE;
        END;
    end;


    var
        myInt: Integer;
        "Approved 1Editable": Boolean;
        "Approved 2Editable": Boolean;
        ContactEditable: Boolean;
        "Broker Contact NameEditable": Boolean;
        "Broker Phone No.Editable": Boolean;

}