page 14229452 "Rebate SubForm ELA"
{


    // ENRE1.00 2021-09-08 AJ
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Rebate Line ELA";
    SourceTableView = SORTING("Rebate Code", "Line No.");

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

                        //<ENRE1.00>
                        CurrPage.Update(true);
                        //</ENRE1.00>
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

                    trigger OnValidate()
                    begin
                        if (Source = Source::Customer) and (Type = Type::"No.") and (Value <> '') then begin
                            "Ship-To Address CodeEditable" := true;
                        end else begin
                            "Ship-To Address CodeEditable" := false;
                        end;
                    end;
                }
                field("Ship-To Address Code"; "Ship-To Address Code")
                {
                    ApplicationArea = All;
                    Editable = "Ship-To Address CodeEditable";
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Rebate Value"; "Rebate Value")
                {
                    ApplicationArea = All;
                    Visible = false;
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

        Source := xRec.Source;
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
        if (Source = Source::Customer) and (Type = Type::"No.") and (Value <> '') then begin
            "Ship-To Address CodeEditable" := true;
        end else begin
            "Ship-To Address CodeEditable" := false;
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

    local procedure ShipToAddressCodeOnActivate()
    begin
        if (Source = Source::Customer) and (Type = Type::"No.") and (Value <> '') then begin
            "Ship-To Address CodeEditable" := true;
        end else begin
            "Ship-To Address CodeEditable" := false;
        end;
    end;

    local procedure ValueOnInputChange(var Text: Text[1024])
    begin
        if (Source = Source::Customer) and (Type = Type::"No.") and (Value <> '') then begin
            "Ship-To Address CodeEditable" := true;
        end else begin
            "Ship-To Address CodeEditable" := false;
        end;
    end;
}

