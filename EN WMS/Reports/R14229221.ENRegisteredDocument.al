report 14229221 "Registered Pick Document ELA"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Registered Pick Document';
    DefaultLayout = RDLC;
    ApplicationArea = All;
    RDLCLayout = './Reports/RegisteredPickDocument.rdl';

    dataset
    {
        dataitem("Registered Whse. Activity Hdr."; "Registered Whse. Activity Hdr.")
        {
            RequestFilterFields = "No.";
            column(No_; "No.")
            {

            }
            dataitem(Integer; Integer)
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(CompanyName; COMPANYPROPERTY.DISPLAYNAME)
                {

                }
                column(TodayFormatted; FORMAT(TODAY, 0, 4))
                {

                }
                column(AssignedUser; "Registered Whse. Activity Hdr."."Assigned User ID")
                {

                }
                column(CurrReportPageNoCaptionLbl; CurrReportPageNoCaptionLbl)
                {

                }
                column(RegisteredPickCaptionLbl; RegisteredPickCaptionLbl)
                {

                }
                dataitem("Registered Whse. Activity Line"; "Registered Whse. Activity Line")
                {
                    DataItemLinkReference = "Registered Whse. Activity Hdr.";
                    DataItemLink = "No." = field("No.");
                    DataItemTableView = WHERE("Action Type" = const(Take));
                    column(Item_No_; "Item No.")
                    {

                    }
                    column(Description; Description)
                    {

                    }
                    column(Unit_of_Measure_Code; "Unit of Measure Code")
                    {

                    }
                    column(Original_Qty; "Original Qty. ELA")
                    {

                    }
                    column(Ordered_Quanity; Quantity)
                    {

                    }
                    column(Container_No__ELA; "Container No. ELA")
                    {

                    }
                    column(Whse__Document_Type; "Whse. Document Type")
                    {

                    }
                    column(Whse__Document_No_; "Whse. Document No.")
                    {

                    }

                }
            }

            trigger OnPreDataItem()
            var

            begin
                "Registered Whse. Activity Hdr.".RESET;
                "Registered Whse. Activity Hdr.".SetRange("No.", RegisterPickNo);
                IF "Registered Whse. Activity Hdr.".FINDSET THEN;
            end;


        }
    }

    procedure SetRegisteredPickNo(RegActNo: Code[20])
    begin
        RegisterPickNo := RegActNo;
    end;

    var

        CurrReportPageNoCaptionLbl: TextConst ENU = 'Page';
        RegisteredPickCaptionLbl: TextConst ENU = 'Registered Pick';
        RegisterPickNo: Code[20];
}

