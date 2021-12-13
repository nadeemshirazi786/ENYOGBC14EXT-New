pageextension 14229616 "EN Item Units of Measure Ext" extends "Item Units of Measure"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(InformationFactBox; "EN Information FactBox")
            {
                ApplicationArea = All;

            }
        }
        addafter("Qty. per Unit of Measure")
        {

            field("Qty. per Base UOM"; "Qty. per Base UOM ELA")
            {
                ApplicationArea = All;
                DecimalPlaces = 0 : 15;

            }

        }

        addafter(Weight)
        {

            field("Item UOM Size Code"; "Item UOM Size Code ELA")
            {
                ApplicationArea = All;

            }
            field("No. of Servings"; "No. of Servings ELA")
            {
                ApplicationArea = All;

            }

        }
    }
    trigger OnOpenPage()
    begin

        // Item.GET("Item No.");
        //ItemBaseUOM := Item."Base Unit of Measure";
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyle();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetStyle();
        UpdateHint();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        UpdateHint();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateHint();
    end;

    local procedure SetStyle()

    begin

        IF Code = ItemBaseUOM THEN
            StyleName := 'Strong'
        ELSE
            StyleName := '';
    end;

    procedure UpdateHint()
    var
        lcduCustom: Codeunit "EN Custom Functions";
    begin


        grecBufferTMP.DELETEALL;

        IF Code <> '' THEN BEGIN
            grecBufferTMP.Text300 := lcduCustom.CalcUOMToText(Rec);
        END ELSE BEGIN
            grecBufferTMP.Text300 := '';
        END;

        CurrPage.InformationFactBox.PAGE.SetInfoRec(grecBufferTMP);
        CurrPage.InformationFactBox.PAGE.UPDATE;

    end;


    var
        Item: Record Item;
        ItemBaseUOM: Code[10];
        StyleName: Text;
        grecBufferTMP: Record "Buffer ELA";
}
