page 14229453 "Recipient Agencies ELA"
{

    // 
    // ENRE1.00
    //   ENRE1.00 - New page
    //   ENRE1.00 - renumbered


    PageType = List;
    SourceTable = "Recipient Agency ELA";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field("Company Contact No."; "Company Contact No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ActivateFields;
                    end;
                }
                field("Primary Contact No."; "Primary Contact No.")
                {
                    ApplicationArea = All;
                    Editable = gblnPrimaryContactEditable;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                        ActivateFields;
                    end;
                }
                field(Contact; Contact)
                {
                    ApplicationArea = All;
                    Editable = gblnContactEditable;

                    trigger OnValidate()
                    begin
                        ActivateFields;
                    end;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Fax No."; "Fax No.")
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("<Action23019016>")
            {
                Caption = '&Recipient Agency';
                action("Co&mments")
                {
                    ApplicationArea = All;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Reci. Agency Comment Sheet ELA";
                    RunPageLink = "Table Name" = CONST("Recipient Agency"),
                                  "No." = FIELD("No."),
                                  "Country/Region Code" = FIELD("Country/Region Code"),
                                  County = FIELD(County);
                }
                action("Commodity Allocations")
                {
                    ApplicationArea = All;
                    Caption = 'Commodity Allocations';
                    Image = Allocate;
                    RunObject = Page "Commodity Allocations ELA";
                    RunPageLink = "Recipient Agency No." = FIELD("No.");
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ActivateFields;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ActivateFields;
    end;

    trigger OnOpenPage()
    begin
        ActivateFields;
    end;

    var
        [InDataSet]
        gblnContactEditable: Boolean;
        [InDataSet]
        gblnPrimaryContactEditable: Boolean;


    procedure ActivateFields()
    begin
        gblnContactEditable := "Primary Contact No." = '';
        gblnPrimaryContactEditable := "Company Contact No." <> '';
    end;
}

