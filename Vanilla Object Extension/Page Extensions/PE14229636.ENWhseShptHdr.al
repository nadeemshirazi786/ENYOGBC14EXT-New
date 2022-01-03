pageextension 14229636 "Whse Shpt ELA" extends "Warehouse Shipment"
{
    layout
    {
        addafter("Shipment Method Code")
        {
            field("Seal No."; "Seal No. ELA")
            {
                ApplicationArea = All;
            }
        }

    }

    actions
    {
        // Add changes to page actions here
    }

    // procedure jfPickCreate()
    // begin
    //     WhseShptLine.COPY(Rec);
    //     WhseShptHeader.GET(WhseShptLine."No.");
    //     IF WhseShptHeader.Status = WhseShptHeader.Status::Open THEN
    //         ReleaseWhseShipment.Release(WhseShptHeader);
    //     jfCreatePickDoc(WhseShptLine, WhseShptHeader);
    // end;

    var
        myInt: Integer;
}