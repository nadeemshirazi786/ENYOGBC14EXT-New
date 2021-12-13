page 14228904 "EN Supply Chain Groups"
{
    Caption = 'Supply Chain Groups';
    PageType = List;
    Permissions = TableData "EN Supply Chain Group User" = rimd;
    SourceTable = "EN Supply Chain Group";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                }
                field(Description; Description)
                {
                }
                field(MyGroup; MyGroup)
                {
                    Caption = 'Include';

                    trigger OnValidate()
                    begin
                        SupplyChainGroupUser."User ID" := UserId;
                        SupplyChainGroupUser."Supply Chain Group Code" := Code;
                        if MyGroup then
                            SupplyChainGroupUser.Insert
                        else
                            SupplyChainGroupUser.Delete;
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002005; Links)
            {
                Visible = false;
            }
            systempart(Control37002006; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Users)
            {
                Caption = 'Users';
                Image = Users;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "EN Supply Chain Group Users";
                RunPageLink = "Supply Chain Group Code" = FIELD(Code);
                RunPageView = SORTING("Supply Chain Group Code");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        MyGroup := SupplyChainGroupUser.Get(UserId, Code);
    end;

    var
        SupplyChainGroupUser: Record "EN Supply Chain Group User";
        [InDataSet]
        MyGroup: Boolean;
}

