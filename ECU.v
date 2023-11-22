module ECU(
    input clk,
    input rst,
    input [9:0] floors_to_visit, // Floors to visit from CCU
    output reg [3:0] current_floor, // Current floor position of this elevator
    output reg direction, // 0 for down, 1 for up
    output reg door_open, // Indicates if the door is open
    output reg idle // Indicates if the elevator is idle
);

    localparam IDLE = 3'b000,
               MOVING_UP = 3'b001,
               MOVING_DOWN = 3'b010,
               DOOR_OPEN = 3'b011,
               DOOR_CLOSE = 3'b100;

    reg [2:0] state = IDLE;
		localparam DOOR_OPEN_TIME = 10000000;
		reg [31:0] door_timer; // Timer for door open duration

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_floor <= 0;
            direction <= 0; // Idle, direction doesn't matter
            door_open <= 0;
            state <= IDLE;
            idle <= 1;
						door_timer <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (|floors_to_visit) begin
                        direction <= (find_next_floor(current_floor, floors_to_visit, direction) > current_floor) ? 1'b1 : 1'b0;
                        state <= (direction) ? MOVING_UP : MOVING_DOWN;
                        idle <= 0;
                    end else begin
                        idle <= 1;
                    end
                end
                MOVING_UP: begin
                    direction <= 1; 
                    if (floors_to_visit[current_floor + 1]) begin
                        current_floor <= current_floor + 1;
                        state <= DOOR_OPEN;
                    end else if (current_floor < find_next_floor(current_floor, floors_to_visit, direction)) begin
                        current_floor <= current_floor + 1;
                    end else begin
                        state <= IDLE;
                    end
                end
                MOVING_DOWN: begin
                    direction <= 0; 
                    if (floors_to_visit[current_floor - 1]) begin
                        current_floor <= current_floor - 1;
                        state <= DOOR_OPEN;
                    end else if (current_floor > find_next_floor(current_floor, floors_to_visit, direction)) begin
                        current_floor <= current_floor - 1;
                    end else begin
                        state <= IDLE;
                    end
                end
                DOOR_OPEN: begin
                    door_open <= 1;
                    if (door_timer < DOOR_OPEN_TIME) begin
                        door_timer <= door_timer + 1;
                    end else begin
                        state <= DOOR_CLOSE;
                        door_timer <= 0; // Reset timer for next door open event
                    end
                end
                DOOR_CLOSE: begin
                    door_open <= 0;
                    floors_to_visit[current_floor] <= 0; // Clear the floor from the visit list
                    state <= IDLE;
                end
            endcase
        end
    end

    
    function [3:0] find_next_floor;
        input [3:0] current_floor;
        input [9:0] floors_to_visit;
        input direction; // Current direction of the elevator
        integer i;
        begin
            find_next_floor = current_floor; // Default to current floor
            if (direction) begin // Elevator is moving up
                for (i = current_floor + 1; i < 10; i = i + 1) begin
                    if (floors_to_visit[i]) begin
                        find_next_floor = i;
                        break;
                    end
                end
            end else begin // Elevator is moving down
                for (i = current_floor - 1; i >= 0; i = i - 1) begin
                    if (floors_to_visit[i]) begin
                        find_next_floor = i;
                        break;
                    end
                end
            end
        end
    endfunction

endmodule