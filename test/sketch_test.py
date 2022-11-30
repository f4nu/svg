import vsketch
import json
import math


class CovidData:
    def __init__(self, vsk, lat, long, cases, province):
        self.vsk = vsk
        self.lat = lat
        self.long = long
        self.cases = cases
        self.province = province

        self.x = 0
        self.y = 0

        self.set_coords()

    def set_coords(self):
        lat_diff = self.vsk.max_latitude() - self.vsk.min_latitude()
        long_diff = self.vsk.max_longitude() - self.vsk.min_longitude()

        lat_to_use = self.lat - self.vsk.min_latitude()
        long_to_use = self.long - self.vsk.min_longitude()

        # lat_to_use : lat_diff = x : max_width
        # long_to_use : long_diff = x : max_height

        x = (long_to_use * self.vsk.max_width()) / long_diff
        y = (lat_to_use * self.vsk.max_height()) / lat_diff

        self.x = x
        self.y = y


class TestSketch(vsketch.Vsketch):
    # Sketch parameters:
    min_latitude = vsketch.Param(36.92509198)
    max_latitude = vsketch.Param(46.49933453)
    min_longitude = vsketch.Param(7.320149366)
    max_longitude = vsketch.Param(18.1718973)
    max_width = vsketch.Param(21)
    max_height = vsketch.Param(29.7)
    min_diameter = vsketch.Param(0.3)
    max_diameter = vsketch.Param(3)
    show_longitude_lines = vsketch.Param(False)

    def draw(self) -> None:
        self.size("a4", landscape=False)
        self.scale("cm")
        #self.polygon([(0, 0), (2, 2), (4, 0)], close=True)
        #self.polygon([(0, 2), (2, 0), (4, 2)], close=True)

        data_to_show = []
        with open("../covid/covid_jan-2021.json", "r") as read_file:
            data = json.load(read_file)
            for datum in data:
                if datum['lat'] is not None and datum['long'] is not None:
                    data_to_show.append(
                        CovidData(self, datum['lat'], datum['long'], datum['totale_casi'], datum['sigla_provincia'])
                    )

        data_to_show.sort(key=lambda x: x.cases, reverse=True)
        max_cases_obj = data_to_show[0]

        data_to_show.sort(key=lambda x: x.lat, reverse=True)
        if self.show_longitude_lines():
            for datum in data_to_show:
                print("%s cases: %s @ %s / %s -> %s / %s" % (datum.province, datum.cases, datum.long, datum.lat, datum.x, datum.y))
                self.line(0, -datum.y, self.max_width(), -datum.y)

        for datum in data_to_show:
            # x : (max_dia - min_dia) = current_cases : max_cases
            current_diameter = ((self.max_diameter() - self.min_diameter()) * datum.cases / max_cases_obj.cases) + self.min_diameter()
            self.circle(datum.x, -datum.y, current_diameter)

        self.vpype("occult")
        return

            # layer = 1
            # for province in data_to_show:
            #     geo_pos = data_to_show[province]
            #     print(geo_pos)
            #
            #     coords = self.get_coords_from_lat_long(geo_pos['lat'], geo_pos['long'])
            #     long_margin = 2
            #     lat_margin = -geo_pos['cases'] / 10000 / 5
            #     # da 0 a long - threshold
            #     first_long_point = coords[0] - long_margin
            #     second_long_point = coords[0] + long_margin
            #     # da long - threshold a long + threshold
            #     # da long + threshold a max_width
            #     self.stroke(layer)
            #     self.draw_noised_line(0, coords[1], first_long_point, coords[1])
            #     self.draw_noised_line(first_long_point, coords[1], first_long_point + long_margin, coords[1] + lat_margin)
            #     self.draw_noised_line(first_long_point + long_margin, coords[1] + lat_margin, second_long_point, coords[1])
            #     self.draw_noised_line(second_long_point, coords[1], self.max_width(), coords[1])
            #     self.close_rect(0, coords[1], self.max_width(), coords[1])
            #     layer += 1
            # return
            # for datum in data:
            #     if datum['totale_casi'] is not None and datum['totale_casi'] != 0 and datum['lat'] is not None and datum['long'] is not None:
            #         total_cases = datum['totale_casi']
            #         #if total_cases > 10000:
            #         #    break
            #
            #         print(datum)
            #         print(total_cases)
            #         total_cases = 1
            #         coords = self.get_coords_from_lat_long(datum['lat'], datum['long'])
            #         print(datum['sigla_provincia'])
            #         self.circle(coords[0], coords[1], total_cases)
            #         #self.vpype('text --position %scm %scm "%s"' % (coords[0], coords[1], datum['denominazione_provincia']))

    def close_rect(self, start_x, start_y, end_x, end_y):
        bottom_y = start_y + 0.5
        self.line(start_x, start_y, start_x, bottom_y)
        self.line(start_x, bottom_y, end_x, bottom_y)
        self.line(end_x, bottom_y, end_x, end_y)

    def draw_noised_line(self, from_x, from_y, to_x, to_y):
        x = from_x
        x_inc = 0.01
        prev_noised_y = 0
        x_samples = (to_x - from_x) / x_inc
        y_inc = (to_y - from_y) / x_samples
        current_y = from_y
        y_delta = math.fabs(to_y - from_y) * 100
        y_has_delta = y_delta != 0
        print("x_samples: %s, y_inc: %s" % (x_samples, y_inc))
        while x < to_x:
            calculated_to_x = x + x_inc
            if calculated_to_x > to_x:
                calculated_to_x = to_x

            current_delta = (math.fabs(current_y - from_y) * 100)
            if y_has_delta and current_delta > 0:
                curve_pct = math.log(current_delta, y_delta)
                print('%s -> %s, y_delta: %s, current_delta: %s, current_y: %s, curve_pct: %s' % (from_y,  to_y, y_delta, current_delta, current_y, curve_pct))
                y = ((current_y - from_y) * curve_pct) + from_y
            else:
                y = current_y
            y_noise = self.noise(x, y) / 8.0
            noised_y = y - y_noise
            if prev_noised_y == 0:
                prev_noised_y = noised_y
            self.line(x, prev_noised_y, calculated_to_x, noised_y)
            x += x_inc
            prev_noised_y = noised_y
            current_y += y_inc

    def get_coords_from_lat_long(self, lat, long):
        lat_diff = self.max_latitude() - self.min_latitude()
        long_diff = self.max_longitude() - self.min_longitude()

        lat_to_use = lat - self.min_latitude()
        long_to_use = long - self.min_longitude()

        # lat_to_use : lat_diff = x : max_width
        # long_to_use : long_diff = x : max_height

        x = (long_to_use * self.max_width()) / long_diff
        y = (lat_to_use * self.max_height()) / lat_diff

        return [x, -y]

    def finalize(self) -> None:
        self.vpype("occult linemerge linesimplify reloop linesort")


if __name__ == "__main__":
    vsk = TestSketch()
    vsk.draw()
    vsk.finalize()
    vsk.display()