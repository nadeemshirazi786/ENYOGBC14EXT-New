page 14229410 "Cancelled Purch Rbt SFrm ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - New Page


    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = ListPart;
    SourceTable = "Cancel Purch. Rbt Line ELA";

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
            {
                ShowCaption = false;
                field(Source; Source)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not (Source = Source::Dimension) then begin
                            "Dimension CodeEditable" := false;
                        end;
                    end;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        SetForm;
                    end;
                }
                field("Sub-Type"; "Sub-Type")
                {
                    ApplicationArea = All;
                    Editable = "Sub-TypeEditable";
                }
                field("Dimension Code"; "Dimension Code")
                {
                    ApplicationArea = All;
                    Editable = "Dimension CodeEditable";
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Include; Include)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetForm;
        OnAfterGetCurrRecord2;
    end;

    trigger OnInit()
    begin
        "Sub-TypeEditable" := true;
        "Dimension CodeEditable" := true;
        "Ship-To Address CodeEditable" := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SetForm;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetForm;
        OnAfterGetCurrRecord2;
    end;

    var
        [InDataSet]
        "Ship-To Address CodeEditable": Boolean;
        [InDataSet]
        "Dimension CodeEditable": Boolean;
        [InDataSet]
        "Sub-TypeEditable": Boolean;


    procedure SetForm()
    begin
        if Type = Type::"No." then begin
            "Sub-TypeEditable" := false;
        end else begin
            "Sub-TypeEditable" := true;
        end;
        if not ((Source = Source::Dimension) and (Type = Type::"No.")) then begin
            "Dimension CodeEditable" := false;
        end else begin
            "Dimension CodeEditable" := true;
        end;
    end;

    local procedure OnAfterGetCurrRecord2()
    begin
        xRec := Rec;
        SetForm;
    end;

    local procedure SubTypeOnActivate()
    begin
        SetForm;
    end;
}

