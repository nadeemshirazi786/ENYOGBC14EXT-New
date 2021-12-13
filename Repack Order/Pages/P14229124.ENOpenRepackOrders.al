page 14229124 "EN Open Repack Orders"
{


    Caption = 'Open Repack Orders';
    CardPageID = "EN Repack Order";
    Editable = false;
    PageType = List;
    SourceTable = "EN Repack Order";
    SourceTableView = SORTING(Status)
                      WHERE(Status = CONST(Open));
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                }
                field("Item No."; "Item No.")
                {
                }
                field("Variant Code"; "Variant Code")
                {
                    Visible = false;
                }
                field(Description; Description)
                {
                }
                field("Lot No."; "Lot No.")
                {
                }
                field(Brand; Brand)
                {
                }
                field(Farm; Farm)
                {
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field("Date Required"; "Date Required")
                {
                }
                field("Due Date"; "Due Date")
                {
                }
                field("Repack Location"; "Repack Location")
                {
                    Visible = false;
                }
                field("Destination Location"; "Destination Location")
                {
                }
                field(Quantity; Quantity)
                {
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }

            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                action(Post)
                {
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        RepackOrder: Record "EN Repack Order";
                        RepackBatchPostMgt: Codeunit "EN Repack Batch Post Mgt.";
                        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
                        BatchPostParameterTypes: Codeunit "Batch Post Parameter Types";
                    begin

                        CurrPage.SetSelectionFilter(RepackOrder);
                        if RepackOrder.Count > 1 then begin
                            BatchProcessingMgt.AddParameter(37002000, true);
                            BatchProcessingMgt.AddParameter(37002001, true);

                            RepackBatchPostMgt.SetBatchProcessor(BatchProcessingMgt);
                            RepackBatchPostMgt.RunWithUI(RepackOrder, RepackOrder.Count, ReadyToPostQst);
                        end else
                            CODEUNIT.Run(CODEUNIT::"Repack-Post (Yes/No)", Rec);
                    end;
                }
                action(PostBatch)
                {
                    Caption = 'Post &Batch';
                    Ellipsis = true;
                    Image = PostBatch;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin

                        REPORT.RunModal(REPORT::"EN Batch Post Repack Orders", true, true, Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
                }
                action(Navigate)
                {
                    Caption = 'Navigate';
                    Image = Navigate;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Navigate;
                    end;
                }
            }
        }
    }

    var
        ReadyToPostQst: Label '%1 out of %2 selected orders are ready for post. \Do you want to continue and post them?', Comment = '%1 - selected count, %2 - total count';
}

