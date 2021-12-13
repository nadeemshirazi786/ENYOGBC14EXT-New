page 14229433 "Purchase Rebate SubForm ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //   20110722 - New Form
    // 
    // ENRE1.00
    //   20111108 - New Fields
    //              - Guaranteed Unit Cost (LCY)
    //              - Guaranteed Cost UOM Code
    // 
    // ENRE1.00
    //   20120418 - Modified Function
    //              - Source - OnValidate()


    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Purchase Rebate Line ELA";

    layout
    {
        area(content)
        {
            repeater(Control23019009)
            {
                ShowCaption = false;
                field(Source; Source)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //<ENRE1.00>
                        SetForm;
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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Include; Include)
                {
                    ApplicationArea = All;
                }
                field("Guaranteed Unit Cost (LCY)"; "Guaranteed Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Guaranteed Cost UOM Code"; "Guaranteed Cost UOM Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    var
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

