tableextension 14229654 "Warehouse Activity Line" extends "Warehouse Activity Line"
{
    fields
    {
        modify("Qty. to Handle")
        {
            trigger OnAfterValidate()
            begin
                IF "Action Type" = "Action Type"::Take THEN BEGIN
                    jfSetUpdatePlaceLine(true);
                END;

                jfUpdatePlaceLine(FIELDNO("Qty. to Handle"));
            end;
        }
    }

    procedure jfSetUpdatePlaceLine(pblnSet: Boolean)
    begin
        IF gblnIsPosting THEN BEGIN
            gblnUpdatePlaceLine := FALSE;
            EXIT;
        END;
        gblnUpdatePlaceLine := pblnSet;
    end;

    procedure jfUpdatePlaceLine(pintFieldNo: Integer)
    var
        lrecWhseActivityLine: Record "Warehouse Activity Line";
        lintUpToLineNo: Integer;
        lintPlaceLineCount: Integer;
    begin
        //Update Place line if there is a single place to single take

        IF "Action Type" = "Action Type"::Place THEN
            EXIT;

        IF NOT gblnUpdatePlaceLine THEN
            EXIT;

        //Find Next take Line
        IF NOT lrecWhseActivityLine.GET("Activity Type", "No.", "Line No.") THEN
            EXIT;

        lrecWhseActivityLine.SETRANGE("Activity Type", "Activity Type");
        lrecWhseActivityLine.SETRANGE("No.", "No.");

        //See if there's a previous Take Line (split take)
        IF lrecWhseActivityLine.NEXT(-1) <> 0 THEN BEGIN
            IF lrecWhseActivityLine."Action Type" = lrecWhseActivityLine."Action Type"::Take THEN
                EXIT;
        END;

        lrecWhseActivityLine.SETFILTER("Line No.", '>%1', "Line No.");
        lrecWhseActivityLine.SETRANGE("Action Type", lrecWhseActivityLine."Action Type"::Take);
        IF lrecWhseActivityLine.FINDFIRST THEN
            lintUpToLineNo := lrecWhseActivityLine."Line No."
        ELSE
            lintUpToLineNo := 0;

        IF lintUpToLineNo <> 0 THEN
            lrecWhseActivityLine.SETRANGE("Line No.", "Line No." + 1, lintUpToLineNo);
        lrecWhseActivityLine.SETRANGE("Action Type", lrecWhseActivityLine."Action Type"::Place);

        lintPlaceLineCount := lrecWhseActivityLine.COUNT;

        IF (lintPlaceLineCount > 1) OR (lintPlaceLineCount = 0) THEN
            EXIT;

        lrecWhseActivityLine.FINDFIRST;

        CASE pintFieldNo OF
            FIELDNO("Qty. to Handle"):
                BEGIN
                    lrecWhseActivityLine.VALIDATE(
                    "Qty. to Handle",
                    ROUND("Qty. to Handle (Base)" / lrecWhseActivityLine."Qty. per Unit of Measure", 0.00001));
                END;
            FIELDNO("Lot No."):
                BEGIN
                    lrecWhseActivityLine.VALIDATE("Lot No.", "Lot No.");
                END;
            FIELDNO("Serial No."):
                BEGIN
                    lrecWhseActivityLine.VALIDATE("Serial No.", "Serial No.");
                END;
        //     //<JF40834SHR>
        //     FIELDNO("Container No."):
        //         BEGIN
        //             lrecWhseActivityLine.VALIDATE("Lot No.", "Lot No.");
        //             lrecWhseActivityLine.VALIDATE("Serial No.", "Serial No.");
        //         END;
        // //</JF40834SHR>
        END;

        lrecWhseActivityLine.MODIFY;
    end;

    procedure jfUpdateIsFromPosting(pblnIsPosting: Boolean)
    begin
        gblnIsPosting := pblnIsPosting;
    end;


    var
        gblnIsPosting: Boolean;
        gblnUpdatePlaceLine: Boolean;

}