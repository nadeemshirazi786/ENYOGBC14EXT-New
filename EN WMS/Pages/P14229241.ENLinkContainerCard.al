page 14229241 "Link Container Card ELA"
{
    //TODO #19 @Kamranshehzad Create report for license plate no 
    //todo #20 @Kamranshehzad add assign content 
    Caption = 'Link Container Card';
    PageType = Document;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Container No."; ContainerNo)
                {
                    Caption = 'Container No.';
                    TableRelation = "Container ELA"."No.";

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Process)
            {
                action("Link")
                {
                    ApplicationArea = Suite;
                    Caption = 'Link';
                    image = Link;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortcutKey = 'F10';
                    ToolTip = 'Link Container';
                    trigger OnAction()
                    var
                        ContMgmt: Codeunit "Container Mgmt. ELA";
                    begin
                        if (WhseActLine."Container No. ELA" <> '') AND (WhseActLine."Container Line No. ELA" <> 0) then begin
                            ContMgmt.RemoveContentToContainerFromLineNo(WhseActLine."Container No. ELA", WhseActLine."Container Line No. ELA");
                        end;
                        ContMgmt.AddContentToContainer(ContainerNo, WhseActLine."Item No.", WhseActLine."Unit of Measure Code", WhseActLine.Quantity
                        , WhseActLine."Lot No.", WhseActLine."Source No.", WhseActLine."Source Line No.", WhseActLine."Whse. Document Type", WhseActLine."Whse. Document No.",
                        WhseActLine."Activity Type", WhseActLine."No.", WhseActLine."Line No.");

                        Message('Container %1 has been assigned successfully.', ContainerNo);
                        CurrPage.Close();
                    end;
                }

                action("Show Container")
                {
                    ApplicationArea = Suite;
                    Caption = 'Show Container';
                    image = View;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortcutKey = 'F2';
                    ToolTip = 'Show Container';
                    trigger OnAction()
                    var
                        Container: record "Container ELA";
                        ContainerCard: page "Container Card ELA";
                    begin
                        if Container.Get(ContainerNo) then begin
                            ContainerCard.SetRecord(Container);
                            ContainerCard.Run();
                        end;


                    end;
                }
            }
        }
    }


    procedure SetWhseActLine(WhseActivityLine: Record "Warehouse Activity Line")
    begin
        WhseActLine := WhseActivityLine;
    end;

    var
        ContainerNo: Code[20];
        WhseActLine: Record "Warehouse Activity Line";
}