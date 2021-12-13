page 51009 "DSD Route Stop Tmplt. Subform"
{
    AutoSplitKey = true;
    DelayedInsert = true;
    ApplicationArea = all;
    UsageCategory = Lists;
    PageType = ListPart;
    PopulateAllFields = true;
    SourceTable = "DSD Route Stop Tmplt. Detail";

    layout
    {
        area(content)
        {
            repeater(Control1102631000)
            {
                ShowCaption = false;
                field("Customer No."; "Customer No.")
                {
                }
                field("Customer Name"; "Customer Name")
                {
                }
                field("Location Code"; "Location Code")
                {
                    Visible = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    Visible = false;
                }
                field(Address; Address)
                {
                }
                field("Address 2"; "Address 2")
                {
                }
                field(City; City)
                {
                }
                field("Post Code"; "Post Code")
                {
                }
                field(County; County)
                {
                }
                field("Delivery Zone Code"; "Delivery Zone Code")
                {
                    Visible = false;
                }
                field("New Sequence"; "New Sequence")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        OnAfterGetCurrentRecord;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnAfterGetCurrentRecord;
    end;

    var
        gtxtDirection: Text[1];

    [Scope('Internal')]
    procedure jxBumpCurrIndex(ptxtDirection: Text[1])
    begin
        gtxtDirection := ptxtDirection;
    end;

    [Scope('Internal')]
    procedure jxUpdate()
    begin
        CurrPage.Update(false);
    end;

    local procedure OnAfterGetCurrentRecord()
    begin
        xRec := Rec;
        if gtxtDirection <> '' then begin
            Find(gtxtDirection);
            gtxtDirection := '';
        end;
    end;
}

