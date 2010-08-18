       IDENTIFICATION           DIVISION.
       PROGRAM-ID.      SHIRITORI.
       ENVIRONMENT              DIVISION.
       INPUT-OUTPUT             SECTION.
       FILE-CONTROL.
        SELECT OPTIONAL S-FILE ASSIGN TO "G:\COBOL\SHIRITORI.TXT"
          ORGANIZATION IS RELATIVE
          ACCESS MODE  IS DYNAMIC
          RELATIVE KEY IS W-NUM.
       
        SELECT ALLOW-LIST ASSIGN "..\04 SHIRITORI_COMMON\ALLOW-LIST.TXT"
          ORGANIZATION LINE SEQUENTIAL.
       DATA                     DIVISION.
       FILE                     SECTION.
       FD S-FILE.
       COPY "S-FILE.CBF".

       FD ALLOW-LIST.
       COPY "ALLOW-LIST.CBF".
       WORKING-STORAGE          SECTION.
       01 IN-STR        PIC X(50).
       01 MY-NAME       PIC X(20).

       78 DEFAULT-NAME  VALUE "������".
       
       01 EOF-FLG       PIC X VALUE LOW-VALUE.
        88 EOF                VALUE HIGH-VALUE.

       01 ERR-FLG       PIC X VALUE LOW-VALUE.
        88 ERR                VALUE HIGH-VALUE.
       
       01 W-NUM         PIC 9(04) VALUE 1.
       
       01 R             PIC 9(02).
       
      * �����񕪊��p�̃e�[�u��
       01 STR-TMP.
           02 C         PIC X(02) OCCURS 25 INDEXED BY P. *> C �� Character �� C

       01 STR-TMP2.
           02 D         PIC X(02) OCCURS 25 INDEXED BY Q. *> C �̎��Ȃ̂� D
       
       01 LOG-TBL.
           02 L         OCCURS 10000 INDEXED BY I. *>����Ƃ肪1����ȏ㑱���Ƃ��������Ȃ�܂�(^^;
             03 L-WORD  PIC X(50).
             03 L-NAME  PIC X(20).

       01 ALLOW-TBL.
           02 A         PIC X(02) OCCURS 100 INDEXED PA. *> �g�p�\�ȂЂ炪��
           02 B         PIC X(02) OCCURS 100 INDEXED PB. *> �g�p�\�ł͂�����̂́A�ꓪ�ɂ͎g���Ȃ�����
       PROCEDURE                DIVISION.
       MAIN.
           PERFORM INIT
           
           PERFORM INPUT-NAME
           
           OPEN INPUT S-FILE
           PERFORM F-READ
           CLOSE S-FILE
           
           PERFORM INPUT-WORD
           PERFORM UNTIL IN-STR = "END" OR "end" OR "�����" OR "�I���"
             IF IN-STR NOT = SPACE
             THEN
               PERFORM CHECK-WORD
               
               IF NOT ERR THEN
                 OPEN I-O S-FILE
                 PERFORM F-WRITE
                 IF ERR THEN
                   PERFORM F-READ
                 END-IF
                 CLOSE S-FILE
               END-IF
             ELSE
               OPEN INPUT S-FILE
               PERFORM F-READ
               CLOSE S-FILE
             END-IF
             PERFORM INPUT-WORD
           END-PERFORM
           STOP RUN.
       
       INIT.
      * =========================================================
      * =                       ������                          =
      * =========================================================
           INITIALIZE LOG-TBL
           MOVE 1 TO W-NUM    *> W-NUM�ɂ͏�ɁA���ɏ������ވʒu������悤�ɂ���
           PERFORM ALLOW-INIT.
       
       ALLOW-INIT.
      * =========================================================
      * =              �g�p�\�ȕ����ꗗ��ǂݍ���             =
      * =========================================================
           OPEN INPUT ALLOW-LIST
           READ ALLOW-LIST INTO ALLOW-TBL
           CLOSE ALLOW-LIST.
       
       INPUT-NAME.
           DISPLAY "���O����͂��Ă��������B"
           ACCEPT MY-NAME
           IF MY-NAME = SPACE THEN
             MOVE DEFAULT-NAME TO MY-NAME
             DISPLAY "�f�t�H���g�̖��O�u" DEFAULT-NAME "�v
      -                                             "�ɐݒ肳��܂����B"
           END-IF.

       INPUT-WORD.
           PERFORM DSP-WORD
           ACCEPT IN-STR.
       
       CHECK-WORD.
           MOVE LOW-VALUE TO ERR-FLG *> �t���O������
           
           IF W-NUM NOT = 1 THEN
             MOVE L-WORD(W-NUM - 1) TO STR-TMP
           END-IF
           MOVE IN-STR TO STR-TMP2
           
           PERFORM CHECK-INVALID-CHAR
           
           IF W-NUM NOT = 1 THEN
             PERFORM CHECK-START-WITH *> ���ڈȍ~�̓��͂̏ꍇ�̂�
           END-IF
           
           PERFORM CHECK-END-WITH
           PERFORM CHECK-CONTAINS.
       
       CHECK-INVALID-CHAR.
       *> �� CHECK-WORD���ł̃`�F�b�N�����̈ꕔ�ł�
       *> ---------------------------------------------------------
       *> - ���͂��ꂽ�����ɁA�g�p�ł��Ȃ��������܂܂�Ă��Ȃ���  -
       *> -   �� �Ђ炪�Ȃƈꕔ�̋L���ȊO�͎g�p�ł��Ȃ�           -
       *> ---------------------------------------------------------
           PERFORM VARYING Q FROM 1 BY 1 UNTIL D(Q) = SPACE
             SET PA TO 1
             SEARCH A
              AT END
             *> �܂�B�Ɏg�p�ł��镶���Ƃ��Ċi�[����Ă���\�������邽�߁A�����ɂ̓G���[��\�����Ȃ�
               SET ERR TO TRUE
              WHEN A(PA) = D(Q)
               CONTINUE
             END-SEARCH
             
             IF ERR THEN
               MOVE LOW-VALUE TO ERR-FLG *> �܂��G���[�ł͂Ȃ��\�������邽��
               SET PB TO 1
               SEARCH B
                AT END
                 SET ERR TO TRUE
                 DISPLAY "!! �u" D(Q) "�v�͎g�p�ł��Ȃ������炵���ł�"
                 EXIT PERFORM
                WHEN B(PB) = D(Q)
                 CONTINUE
               END-SEARCH
             END-IF
           END-PERFORM.
       
       CHECK-START-WITH.
       *> �� CHECK-WORD���ł̃`�F�b�N�����̈ꕔ�ł�
       *> ------------------------------------------------------------
       *> - ���͂��ꂽ�P�ꂪ�A�O�̒P��̍Ō�̕�������n�܂��Ă��邩 -
       *> ------------------------------------------------------------
           PERFORM FIND-CHAR
           IF C(P) NOT = D(1) THEN
             SET ERR TO TRUE
             DISPLAY "!! �u" C(P) "�v����n�܂�P�����͂��Ă�������"
           END-IF.
       
       CHECK-END-WITH.
       *> �� CHECK-WORD���ł̃`�F�b�N�����̈ꕔ�ł�
       *> ---------------------------------------------------------
       *> -       ���͂��ꂽ�P�ꂪ�u��v�ŏI����Ă��Ȃ���        -
       *> ---------------------------------------------------------
           PERFORM FIND-CHAR2
           IF D(Q) = "��" THEN
             SET ERR TO TRUE
             DISPLAY "!! ���͂��ꂽ�P�ꂪ�u��v�ŏI����Ă��܂�"
           END-IF.
       
       CHECK-CONTAINS.
       *> �� CHECK-WORD���ł̃`�F�b�N�����̈ꕔ�ł�
       *> ---------------------------------------------------------
       *> -        ���͂��ꂽ�P�ꂪ���łɎg���Ă��Ȃ���         -
       *> ---------------------------------------------------------
           SET I TO 1
           SEARCH L
            AT END CONTINUE
            WHEN L-WORD(I) = SPACE  CONTINUE  *> SPACE�ȍ~�ɂ̓f�[�^������
            WHEN L-WORD(I) = IN-STR
             SET ERR TO TRUE
             DISPLAY "!! ���̒P��͂����g���Ă���炵���ł���"
           END-SEARCH.
       
       FIND-CHAR.
       *> =========================================================
       *> =          STR-TMP���̍Ō�̕����̈ʒu��T��            =
       *> =========================================================
           PERFORM VARYING P FROM 1 BY 1 UNTIL C(P) = SPACE
             CONTINUE
           END-PERFORM
           SET P DOWN BY 1
           
         *> �Ō�̕������u�[�v�u�B�v�u�A�v�Ȃǂł���Ί����߂�
           PERFORM VARYING P FROM P BY -1 UNTIL P = 0
             SET PB TO 1
             SEARCH B
              AT END
               EXIT PERFORM            *> �����߂��������Ȃ���΃��[�v�𔲂���
              WHEN B(PB) = C(P)
               CONTINUE                *> �������͉������Ȃ��Ń��[�v�𑱂���
             END-SEARCH
           END-PERFORM.
       
       FIND-CHAR2.
       *> =========================================================
       *> =         STR-TMP2���̍Ō�̕����̈ʒu��T��            =
       *> =========================================================
           PERFORM VARYING Q FROM 1 BY 1 UNTIL D(Q) = SPACE
             CONTINUE
           END-PERFORM
           SET Q DOWN BY 1
           
         *> �Ō�̕������u�[�v�u�B�v�u�A�v�Ȃǂł���Ί����߂�
           PERFORM VARYING Q FROM Q BY -1 UNTIL Q = 0
             SET PB TO 1
             SEARCH B
              AT END
               EXIT PERFORM            *> �����߂��������Ȃ���΃��[�v�𔲂���
              WHEN B(PB) = D(Q)
               CONTINUE                *> �������͉������Ȃ��Ń��[�v�𑱂���
             END-SEARCH
           END-PERFORM.
       
       DSP-WORD.
           IF W-NUM = 1
           THEN
             DISPLAY SPACE
             DISPLAY "�܂��N���P�����͂��Ă��܂���B"
           ELSE
             DISPLAY SPACE
             DISPLAY "*** ���O�ɑ���ꂽ�P��T�� ***"
             
      *       ���O��5�܂ł�\������
             SET I TO W-NUM
             SET I DOWN BY 5
             IF I < 1 THEN
               SET I TO 1
             END-IF
             PERFORM VARYING I FROM I BY 1 UNTIL I = W-NUM
               DISPLAY L-WORD(I) SPACE "(" L-NAME(I) ")"
             END-PERFORM
             
             SUBTRACT 1 FROM W-NUM
             DISPLAY "�����܂� " W-NUM " �̒P�ꂪ���͂���܂����B"
             ADD 1 TO W-NUM
             
             MOVE L-WORD(W-NUM - 1) TO STR-TMP
             PERFORM FIND-CHAR
             DISPLAY SPACE
             DISPLAY "�u" C(P) "�v����n�܂�P�����͂��Ă��������B"
           END-IF.
       
       F-READ.
      *     �O��ǂݍ��񂾏ꏊ���瑱����ǂݍ��߂Ηǂ����߁A
      *     MOVE 1 TO W-NUM �͕s�v�ƂȂ�B
           MOVE LOW-VALUE TO EOF-FLG
           PERFORM UNTIL EOF
             READ S-FILE
               INVALID KEY  SET EOF TO TRUE
               NOT INVALID KEY
                 MOVE S-WORD TO L-WORD(W-NUM)
                 MOVE S-NAME TO L-NAME(W-NUM)
                 ADD 1 TO W-NUM
             END-READ
           END-PERFORM.
       
       F-WRITE.
           MOVE LOW-VALUE TO ERR-FLG
           SET I TO 1
           SEARCH L
             AT END
               MOVE IN-STR  TO S-WORD L-WORD(W-NUM)
               MOVE MY-NAME TO S-NAME L-NAME(W-NUM)
               WRITE S-REC
                 INVALID KEY
                   DISPLAY "!! �N������ɏ�������ł��܂����悤�ł��B"
                   SET ERR TO TRUE
                 NOT INVALID KEY
                   ADD 1 TO W-NUM
               END-WRITE
             WHEN L-WORD(I) = IN-STR
               DISPLAY "!! ���̒P��͊��Ɏg���Ă��܂��B"
               SET ERR TO TRUE
           END-SEARCH.

