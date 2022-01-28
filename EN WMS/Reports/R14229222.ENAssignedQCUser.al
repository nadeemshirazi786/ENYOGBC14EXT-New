report 14229222 "Assigned QC User ELA"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(DataItemName; Integer)
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = CONST(1));
            /*trigger OnAfterGetRecord()
            var
                ShipmentManagement: Codeunit "Shipment Mgmt. ELA";
            begin
                ShipmentManagement.WhseShipmentReleaseToQC(ShipmentDocumentNo, ShipmentDocumentLineNo, ReleaseToQC, AssignedQCUser);
            end;*/

        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Assigned QC User")
                {

                    field(QCUserInput; AssignedQCUser)
                    {
                        Caption = 'Assiged QC User:';
                        TableRelation = "Application User ELA"."User ID";
                        ApplicationArea = All;

                    }
                }
            }
        }

    }
    trigger OnPreReport()
    begin
        ReportStarted := TRUE;
    end;



    procedure ExecutedOk(var AssignedUser: Code[20]): Boolean
    begin
        AssignedUser := AssignedQCUser;
        Exit(ReportStarted);
    end;

    procedure SetShipmentDoc(ShipmentDocNo: Code[20]; ShipmentDocLineNo: Integer; ReleaseToQCVal: Boolean)
    begin

        ShipmentDocumentNo := ShipmentDocNo;
        ShipmentDocumentLineNo := ShipmentDocLineNo;
        ReleaseToQC := ReleaseToQCVal;
    end;



    var
        AssignedQCUser: Code[20];
        ShipmentDocumentNo: Code[20];
        ShipmentDocumentLineNo: Integer;
        ShipmentLine: Record "Warehouse Shipment Line";
        ShipDashMgmt: Codeunit "Shipment Mgmt. ELA";
        ReportStarted: Boolean;
        ReleaseToQC: Boolean;
}