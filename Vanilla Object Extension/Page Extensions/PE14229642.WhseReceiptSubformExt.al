pageextension 14229642 "Whse. Receipt Subform" extends "Whse. Receipt Subform"
{
    layout
    {
        addafter("Qty. Received")
        {
            field("Receiving UOM ELA"; "Receiving UOM ELA")
            {
                Caption = 'Receiving Unit of Measure';
            }
            field("Tracking Status ELA"; txtTrackingStatus)
            {
                Caption = 'Tracking Status';
            }
            field("UOM Size Code"; isGetUOMSizeCode)
            {
                Caption = 'UOM Size Code';
            }
        }

    }
    trigger OnAfterGetRecord()
    var
        gcodTrackingStatus: Codeunit "EN Custom Functions";
        ldecPct: Decimal;
        lblnItemTracking: Boolean;
    begin

        // SetStatus; //<JF49590SHR>

        //<WC32455WC>
        ldecPct := ROUND(doTrackingExistsELA("Qty. (Base)", lblnItemTracking));
        txtTrackingStatus := gcodTrackingStatus.UpdateTrackingStatus(ldecPct, lblnItemTracking);
        StyleTxt := gcodTrackingStatus.SetStyle(ldecPct, lblnItemTracking);
    end;

    procedure isGetUOMSizeCode(): CODE[20]
    var
        lrecItemUOM: Record "Item Unit of Measure";
    begin
        IF "Item No." = '' THEN EXIT('');
        IF "Unit of Measure Code" = '' THEN EXIT('');
        IF lrecItemUOM.GET("Item No.", "Unit of Measure Code") THEN;
        EXIT(lrecItemUOM."Item UOM Size Code ELA");
    end;

    var
        txtTrackingStatus: Code[20];
        StyleTxt: Text[50];

}