Report 14229220 "Adjust Whse. Shipment Qty ELA"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(DataItemName; Integer)
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = CONST(1));
            trigger OnAfterGetRecord()
            begin
                WhseSetup.Get;
                //<<EN1.03
                IF NOT HideDialogBox THEN BEGIN //<<EN1.02

                    IF WinResponse <= 0 THEN
                        ERROR(TXT006);

                    NewEnteredQty := WinResponse;


                    //<<EN1.05
                    IF NewEnteredQty < 0 THEN
                        ERROR('You cannot enter negative qty. Please enter the new quantity');

                END;  //<<EN1.02  + EN1.05
                WMSServices.WhseAdjustmentQty(RegWhseActivityType, RegWhseActivityNo, RegWhseActivityLineNo, ItemNo, ItemDesc, ShipmentNo, ShipmentLineNo, ContainerNo, ContainerLineNo, NewEnteredQty, ReasonCode, HideDialogBox);
            end;
        }

    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Item Adjustment")
                {
                    field(ValueInput; WinResponse)
                    {
                        Caption = 'Enter Value to Adjust:';
                        ApplicationArea = All;

                    }
                    field(ReasonInput; ReasonCode)
                    {
                        Caption = 'Reason:';
                        TableRelation = "Reason Code";
                        ApplicationArea = All;

                    }
                }
            }
        }
    }

    procedure SetParam(RegWhseActType: Option ,"Put-away",Pick,Movement; RegWhsActNo: Code[20]; RegWhseActLineNo: Integer; NewItemNo: Code[20]; NewItemDesc: text[50]; NewShipmentNo: Code[20]; NewShipmentLineNo: Integer; NewContId: Code[20]; NewContContent: Integer; NewAdjQty: Decimal)
    begin

        ItemNo := NewItemNo;
        ItemDesc := NewItemDesc;
        ShipmentNo := NewShipmentNo;
        ShipmentLineNo := NewShipmentLineNo;
        ContainerNo := NewContId;
        ContainerLineNo := NewContContent;
        RegWhseActivityType := RegWhseActType;
        RegWhseActivityNo := RegWhsActNo;
        RegWhseActivityLineNo := RegWhseActLineNo;
        HideDialogBox := false;
        //<<EN1.02

    end;



    var
        WhseSetup: Record "Warehouse Setup";
        WMSServices: Codeunit "WMS Activity Mgmt. ELA";
        RegWhseActivityType: Option ,"Put-away",Pick,Movement;
        RegWhseActivityNo: Code[20];
        RegWhseActivityLineNo: Integer;
        ItemNo: Code[20];
        ItemDesc: Text[50];
        ShipmentNo: Code[20];
        ShipmentLineNo: Integer;
        ContainerLineNo: Integer;
        NewEnteredQty: Decimal;
        HideDialogBox: Boolean;
        ContainerNo: Code[20];
        WinResponse: Integer;
        ReasonCode: Code[20];
        TXT006: TextConst ENU = 'Please enter the valid New Qty';
}