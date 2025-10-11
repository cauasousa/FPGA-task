Enunciado: Desenvolver a capacidade de projetar, modelar, simular e implementar circuitos digitais por meio da linguagem VHDL (VHSIC Hardware Description Language), promovendo a compreensão dos conceitos de lógica digital e sua aplicação prática no desenvolvimento de sistemas embarcados e dispositivos programáveis, como FPGAs.
Objetivo: Desenvolva em SystemVerilog um circuito lógico para acionar dois motores (M1 e M2) de forma alternada: liga-se um motor por 30 s, em seguida desliga-se este e liga-se o outro por 30 s, repetindo o ciclo continuamente até receber comando de parada.

Conexões FPGA no P3 com a Primeira BitDogLab 1(InterfaceFPGA_1):
- GP18 -> PL23D
- GP19 -> PL17C
- GP20 -> PL14B
- GP4  -> PL5C
- GP9  -> PL8C
- GP8  -> PL11B
- GP16 -> PL17B
- GP17 -> PL17A
- GP28 -> PL14D

Conexões com a Segunda BitDogLab(InterfaceFPGA_2):
- PL5B (conectado à segunda BitDogLab)

Observações:
- Você precisa exportar as interfaces para poder executar.
- A primeira BitDogLab deve ser usada para realizar a parte principal do objetivo (acionamento alternado dos motores M1 e M2).
- A segunda BitDogLab deve ser usada para acender o LED da segunda BitDogLab.


Nota: As conexões acima descrevem os pinos do FPGA (GPx) mapeados para os pads PLxx do conector BitDogLab conforme indicado pelo usuário. Certifique-se de verificar o manual de pinagem do seu cartão/placa antes de realizar as ligações físicas para evitar danos por mau contato ou mapeamento incorreto.