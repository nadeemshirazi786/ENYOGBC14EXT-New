pageextension 14229644 "Whse Recepit" extends "Warehouse Receipt"
{
    layout
    {
        addafter(WhseReceiptLines)
        {
            group(Shipping)
            {
                field("Shipping Agent Code ELA"; "Shipping Agent Code ELA")
                {
                    Caption = 'Shipping Agent Code';
                }
                field("Act. Delivery Appointment Date"; "Act. Delivery Appointment Date")
                {

                }
                field("Act. Delivery Appointment Time"; "Act. Delivery Appointment Time")
                {

                }
                field("Exp. Delivery Appointment Date"; "Exp. Delivery Appointment Date")
                {

                }
                field("Exp. Delivery Appointment Time"; "Exp. Delivery Appointment Time")
                {

                }
            }
        }
    }

    actions
    {
        addfirst(Processing)
        {
            action("Show Container")
            {
                ApplicationArea = Suite;
                Caption = '&Container';
                Image = ResourceGroup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';
                ToolTip = 'Shows Items in the container';
                trigger OnAction()
                var
                    ContMgmt: Codeunit "Container Mgmt. ELA";
                    WhseDocType: enum "Whse. Doc. Type ELA";
                    SourceDocTypeFilter: enum "WMS Source Doc Type ELA";
                    ActivityType: Enum "WMS Activity Type ELA";
                begin
                    //PostDocument(Rec);
                    ContMgmt.ShowContainer(SourceDocTypeFilter, '', "Location Code", 0, '', WhseDocType::Receipt, "No.",
                        ActivityType, '');
                end;
            }


        }
    }

    var
        myInt: Integer;
}