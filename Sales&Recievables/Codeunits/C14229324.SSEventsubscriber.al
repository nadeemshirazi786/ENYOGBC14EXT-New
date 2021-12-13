codeunit 14228821 "S&S Event subscriber"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, 42, 'OnResolveCaptionClass', '', true, true)]
    local procedure ResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer)
    begin
        case CaptionArea of
            '23019060':
                GlobalGroupCaptions(Language, COPYSTR(CaptionExpr, 1, 80));
        end;
    end;

    local procedure GlobalGroupCaptions(Language: Integer; CaptionExpr: Text[80]): Text[80]
    var
        CaptionType: Text;
        CaptionRef: Text;
        DimOptionalParam1: Text;
        DimOptionParam2: Text;
        ComaPostion: Integer;
        SRSetup: Record "Sales & Receivables Setup";
        GlobalGroup: Record "Global Group ELA";
        PPSetup: Record "Purchases & Payables Setup";
        InvtSetup: Record "Inventory Setup";
    begin
        ComaPostion := STRPOS(CaptionExpr, ',');
        IF (ComaPostion > 0) THEN BEGIN
            CaptionType := COPYSTR(CaptionExpr, 1, ComaPostion - 1);
            CaptionRef := COPYSTR(CaptionExpr, ComaPostion + 1);
            ComaPostion := STRPOS(CaptionRef, ',');

            CASE CaptionType OF
                '1':
                    BEGIN

                        IF NOT GetSRSetup THEN
                            EXIT('');

                        CASE CaptionRef OF
                            '1':
                                BEGIN
                                    IF SRSetup."Global Group 1 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(SRSetup."Global Group 1 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(SRSetup.FIELDCAPTION("Global Group 1 Code ELA"));
                                    END;
                                END;
                            '2':
                                BEGIN
                                    IF SRSetup."Global Group 2 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(SRSetup."Global Group 2 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(SRSetup.FIELDCAPTION("Global Group 2 Code ELA"));
                                    END;
                                END;
                            '3':
                                BEGIN
                                    IF SRSetup."Global Group 3 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(SRSetup."Global Group 3 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(SRSetup.FIELDCAPTION("Global Group 3 Code ELA"));
                                    END;
                                END;
                            '4':
                                BEGIN
                                    IF SRSetup."Global Group 4 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(SRSetup."Global Group 4 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(SRSetup.FIELDCAPTION("Global Group 4 Code ELA"));
                                    END;
                                END;
                            '5':
                                BEGIN
                                    IF SRSetup."Global Group 5 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(SRSetup."Global Group 5 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(SRSetup.FIELDCAPTION("Global Group 5 Code ELA"));
                                    END;
                                END;

                        END;
                    END;

                '2':
                    BEGIN

                        IF NOT GetInvtSetup THEN
                            EXIT('');

                        CASE CaptionRef OF
                            '1':
                                BEGIN
                                    IF InvtSetup."Global Group 1 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(InvtSetup."Global Group 1 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(InvtSetup.FIELDCAPTION("Global Group 1 Code ELA"));
                                    END;
                                END;
                            '2':
                                BEGIN
                                    IF InvtSetup."Global Group 2 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(InvtSetup."Global Group 2 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(InvtSetup.FIELDCAPTION("Global Group 2 Code ELA"));
                                    END;
                                END;
                            '3':
                                BEGIN
                                    IF InvtSetup."Global Group 3 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(InvtSetup."Global Group 3 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(InvtSetup.FIELDCAPTION("Global Group 3 Code ELA"));
                                    END;
                                END;
                            '4':
                                BEGIN
                                    IF InvtSetup."Global Group 4 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(InvtSetup."Global Group 4 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(InvtSetup.FIELDCAPTION("Global Group 4 Code ELA"));
                                    END;
                                END;
                            '5':
                                BEGIN
                                    IF InvtSetup."Global Group 5 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(InvtSetup."Global Group 5 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(InvtSetup.FIELDCAPTION("Global Group 5 Code ELA"));
                                    END;
                                END;

                        END;
                    END;

                '3':
                    BEGIN

                        IF NOT GetPPSetup THEN
                            EXIT('');

                        CASE CaptionRef OF
                            '1':
                                BEGIN
                                    IF PPSetup."Global Group 1 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(PPSetup."Global Group 1 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(PPSetup.FIELDCAPTION("Global Group 1 Code ELA"));
                                    END;
                                END;
                            '2':
                                BEGIN
                                    IF PPSetup."Global Group 2 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(PPSetup."Global Group 2 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(PPSetup.FIELDCAPTION("Global Group 2 Code ELA"));
                                    END;
                                END;
                            '3':
                                BEGIN
                                    IF PPSetup."Global Group 3 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(PPSetup."Global Group 3 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(PPSetup.FIELDCAPTION("Global Group 3 Code ELA"));
                                    END;
                                END;
                            '4':
                                BEGIN
                                    IF PPSetup."Global Group 4 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(PPSetup."Global Group 4 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(PPSetup.FIELDCAPTION("Global Group 4 Code ELA"));
                                    END;
                                END;
                            '5':
                                BEGIN
                                    IF PPSetup."Global Group 5 Code ELA" <> '' THEN BEGIN
                                        GlobalGroup.GET(PPSetup."Global Group 5 Code ELA");
                                        EXIT(GlobalGroup."Code Caption");
                                    END ELSE BEGIN
                                        EXIT(PPSetup.FIELDCAPTION("Global Group 5 Code ELA"));
                                    END;
                                END;

                        END;
                    END;
            end;
        end;
    end;
    procedure GetSRSetup(): Boolean
    var
        SRSetupRead: Boolean;
        SRSetup: Record "Sales & Receivables Setup";

    begin

        IF NOT SRSetupRead THEN
            SRSetupRead := SRSetup.GET;
        EXIT(SRSetupRead);
    end;
    procedure GetInvtSetup(): Boolean
    var
        InvtSetupRead: Boolean;
        InvtSetup: Record "Inventory Setup";
    begin

        IF NOT InvtSetupRead THEN
            InvtSetupRead := InvtSetup.GET;
        EXIT(InvtSetupRead);
    end;

    procedure GetPPSetup(): Boolean
    var
        PPSetupRead: Boolean;
        PPSetup: Record "Purchases & Payables Setup";
    begin

        IF NOT PPSetupRead THEN
            PPSetupRead := PPSetup.GET;
        EXIT(PPSetupRead);
    end;
    


}
