module CCU(
    input clk,
    input rst,
    input [19:0] external_requests, // 10 floors, 2 bits per floor (up and down)
    input [9:0] internal_requests_elevator1, // Internal requests for elevator 1
    input [9:0] internal_requests_elevator2, // Internal requests for elevator 2
    input [3:0] current_floor_elevator1,
    input [3:0] current_floor_elevator2,
    input direction_elevator1, // 1 for up, 0 for down
    input direction_elevator2,
    input idle_elevator1,
    input idle_elevator2,
    output reg [9:0] floors_to_visit_elevator1, // Floors to visit for elevator 1
    output reg [9:0] floors_to_visit_elevator2  // Floors to visit for elevator 2
);

    // Task to update floors to visit
    task update_floors_to_visit;
        input [9:0] internal_requests;
        input [19:0] external_requests;
        input [3:0] current_floor;
        input direction;
        input idle;
        inout [9:0] floors_to_visit;
        integer i;
        reg [3:0] closest_request;
        begin
            floors_to_visit = 0; // Reset floors to visit
            closest_request = 10; // Initialize with an invalid floor number

            // If the elevator is idle, find the nearest request regardless of direction
            if (idle) begin
                closest_request = find_nearest_request(internal_requests, external_requests, current_floor);
                if (closest_request != 10) begin
                    floors_to_visit[closest_request] = 1;
                end
            end else begin
                // Update floors to visit based on current direction
                if (direction) begin // Elevator is moving up
                    for (i = current_floor + 1; i < 10; i = i + 1) begin
                        if (internal_requests[i] || external_requests[2 * i]) begin
                            floors_to_visit[i] = 1;
                        end
                    end
                end else begin // Elevator is moving down
                    for (i = current_floor - 1; i >= 0; i = i - 1) begin
                        if (internal_requests[i] || external_requests[2 * i + 1]) begin
                            floors_to_visit[i] = 1;
                        end
                    end
                end
            end
        end
    endtask

    // Function to find the nearest request
    function [3:0] find_nearest_request;
        input [9:0] internal_requests;
        input [19:0] external_requests;
        input [3:0] current_floor;
        integer i;
        reg [3:0] up_distance, down_distance;
        begin
            find_nearest_request = 10; // Initialize with an invalid floor number
            up_distance = 10;
            down_distance = 10;
            
            // Check each floor for the nearest request
            for (i = 0; i < 10; i = i + 1) begin
                if (internal_requests[i] || external_requests[2 * i] || external_requests[2 * i + 1]) begin
                    if (i > current_floor && (i - current_floor < up_distance)) begin
                        up_distance = i - current_floor;
                        find_nearest_request = i;
                    end
                    if (i < current_floor && (current_floor - i < down_distance)) begin
                        down_distance = current_floor - i;
                        find_nearest_request = i;
                    end
                end
            end
        end
    endfunction

    // Main control logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            floors_to_visit_elevator1 <= 0;
            floors_to_visit_elevator2 <= 0;
        end else begin
            // Update floors to visit for each elevator
            update_floors_to_visit(internal_requests_elevator1, external_requests, current_floor_elevator1, direction_elevator1, idle_elevator1, floors_to_visit_elevator1);
            update_floors_to_visit(internal_requests_elevator2, external_requests, current_floor_elevator2, direction_elevator2, idle_elevator2, floors_to_visit_elevator2);
        end
    end

endmodule