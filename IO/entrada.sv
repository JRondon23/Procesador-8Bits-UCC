
module entrada (
    input logic clk, rst,
    input logic [3:0] dato_usuario,
    input logic boton,
    input logic habilitar, aceptar,
    output logic [7:0] dato_entrada,
    output logic dato_listo
);
    logic [3:0] dato_etapa1, dato_sync, dato_limpio;
    logic boton_etapa1, boton_sync, boton_limpio;
    logic dato_estable, boton_estable;
    logic boton_liberado, pulso;
    logic [3:0] mitad_superior;
    logic mitad_pendiente;

 
    always_ff @(posedge clk) begin
        if (rst) begin
            dato_etapa1		 <= 0;
            dato_sync 		 <= 0;
            boton_etapa1 	 <= 0;
            boton_sync 		 <= 0;
        end else begin
            dato_etapa1 	<= dato_usuario;
            dato_sync 		<= dato_etapa1;
            boton_etapa1 	<= !boton;
            boton_sync 		<= boton_etapa1;
        end
    end

    filtro antirrebote (
        .clk					(clk), 
		  .rst					(rst),
        .dato					(dato_sync), 
		  .boton					(boton_sync),
        .dato_limpio			(dato_limpio), 
		  .boton_limpio		(boton_limpio),
        .dato_estable		(dato_estable), 
		  .boton_estable		(boton_estable)
    );


    always_ff @(posedge clk) begin
        if (rst) begin
            pulso <= 0;
            boton_liberado <= 0;
        end else begin
            pulso <= 0;
            if (boton_estable) begin
                if (!boton_limpio)
                    boton_liberado <= 1;
                else if (boton_liberado) begin
                    pulso <= 1;
                    boton_liberado <= 0;
                end
            end
        end
    end


    always_ff @(posedge clk) begin
        if (rst) begin
            mitad_superior <= 0;
            mitad_pendiente <= 0;
            dato_entrada <= 0;
            dato_listo <= 0;
        end else if (aceptar) begin
            dato_listo <= 0;
            mitad_pendiente <= 0;
        end else if (!habilitar) begin
            mitad_pendiente <= 0;
            dato_listo <= 0;
        end else if (pulso && dato_estable && !dato_listo) begin
            if (!mitad_pendiente) begin
                mitad_superior <= dato_limpio;
                mitad_pendiente <= 1;
            end else begin
                dato_entrada <= {mitad_superior, dato_limpio};
                dato_listo	 <= 1;
                mitad_pendiente <= 0;
            end
        end
    end
endmodule


module filtro (
    input logic clk, rst,
    input logic [3:0] dato,
    input logic boton,
    output logic [3:0] dato_limpio,
    output logic boton_limpio,
    output logic dato_estable, boton_estable
);
    localparam integer CICLOS = 500000;
    logic [3:0] candidato_dato;
    logic candidato_boton;
    logic [18:0] contador_dato, contador_boton;

    assign dato_estable = (dato == candidato_dato) && (dato_limpio == candidato_dato) && (contador_dato == CICLOS - 1);
    assign boton_estable = (boton == candidato_boton) && (boton_limpio == candidato_boton) && (contador_boton == CICLOS - 1);

    always_ff @(posedge clk) begin
        if (rst) begin
            candidato_dato <= 0;
            dato_limpio <= 0;
            contador_dato <= 0;
        end else if (dato != candidato_dato) begin
            candidato_dato <= dato;
            contador_dato <= 0;
        end else if (contador_dato < CICLOS - 1) begin
            contador_dato <= contador_dato + 1'b1;
        end else begin
            dato_limpio <= candidato_dato;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            candidato_boton <= 0;
            boton_limpio <= 0;
            contador_boton <= 0;
        end else if (boton != candidato_boton) begin
            candidato_boton <= boton;
            contador_boton <= 0;
        end else if (contador_boton < CICLOS - 1) begin
            contador_boton <= contador_boton + 1'b1;
        end else begin
            boton_limpio <= candidato_boton;
        end
    end
endmodule
