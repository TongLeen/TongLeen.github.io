<script setup lang="ts">

import { onMounted } from 'vue';

onMounted(async () => {
    const JXG = (await import('jsxgraph')).default;
    let board = JXG.JSXGraph.initBoard('jxgbox',
        {
            boundingbox: [-3.5, 6, 3.5, -10],
            showCopyright: false,
            showNavigation: false,
        }
    );
    const line = (p1: unknown, p2: unknown) =>
        board.create('line', [p1, p2],
            {
                straightFirst: false, straightLast: false,
                strokeWidth: 1
            }
        )

    const Ef = -1.4;
    const intrinsic_k = 5

    board.create(
        'line',
        [[0, Ef], [1, Ef]],
        { strokeWidth: 1, strokeColor: "green", fixed: true }
    );
    board.create(
        'text',
        [-2, -0.1, "Ef"],
        { color: "green", fixed: true }
    )

    let esd_input = board.create(
        'slider',
        [[-3, -8], [0, -8], [0.1, 0.5, 0.9]],
        { name: "ESD" }
    )

    let thickness = board.create(
        'slider',
        [[-3, -9], [0, -9], [0.2, 0.5, 2]],
        { name: "thickness" }
    )

    const DeltaEC = 2
    const AlGaN_EG = 6
    const GaN_EG = 3


    const Esd = () => (
        thickness.Value() * intrinsic_k + DeltaEC - AlGaN_EG * (1 - esd_input.Value())
    )

    const EsdOverEf = () => (
        Esd() - Ef
    )

    const is2DEGexist = () => EsdOverEf() > -Ef

    const interfaceShift = () => {
        if (is2DEGexist()) {
            return -Ef + Math.log10(EsdOverEf() + 1 + Ef) * 0.5
        }
        else {
            return Math.max(EsdOverEf(), 0)
        }
    }

    const surfaceShift = () => {
        return thickness.Value() * intrinsic_k - Math.max(EsdOverEf(), 0)
    }



    const GaN_Band = (drop: () => number) => {
        let Ec_points = [0, 0.01, 0.1, 2].map(
            (n, index) => {
                return board.create(
                    'point',
                    (index === 0) ?
                        [0, (() => -drop())] : [n, 0],
                    { visible: false }
                )
            })
        const GaN_Ec2Ev = board.create('transform', [0, -GaN_EG], { type: 'translate' })
        let Ev_points = Ec_points.map(
            (p) => board.create(
                'point', [p, GaN_Ec2Ev], { visible: false }
            )
        )
        board.create('curve', JXG.Math.Numerics.bezier(Ec_points))
        board.create('curve', JXG.Math.Numerics.bezier(Ev_points))
        line(Ec_points.at(-1), Ev_points.at(-1))
    }

    type AlGaN_Band_Type = (
        width: () => number,
        interfaceShift: () => number,
        surfaceShift: () => number,
        eds: () => number,
    ) => void

    const AlGaN_Band: AlGaN_Band_Type = (
        width,
        interfaceShift,
        surfaceShift,
        esd) => {
        const Ec_right = board.create(
            'point',
            [0, () => DeltaEC - interfaceShift()],
            { visible: false }
        )
        const Ec_left = board.create(
            'point',
            [() => 0 - width(), () => DeltaEC + surfaceShift()],
            { visible: false }
        )
        line(Ec_right, Ec_left)
        const Ev_right = board.create(
            'point',
            [0, () => DeltaEC - AlGaN_EG - interfaceShift()],
            { visible: false }
        )
        const Ev_left = board.create(
            'point',
            [() => 0 - width(), () => DeltaEC - AlGaN_EG + surfaceShift()],
            { visible: false }
        )
        line(Ev_right, Ev_left);
        line(Ec_right, [0, () => (0 - interfaceShift())]);
        line(Ev_right, [0, () => (-GaN_EG - interfaceShift())]);
        line(Ec_left, Ev_left);
        let esd_point = board.create(
            'point',
            [() => -width(), () => Ev_left.Y() + esd() * AlGaN_EG],
            { name: "Esd", label: { offset: [-30, 0] } }
        )
    }


    GaN_Band(interfaceShift)
    AlGaN_Band(
        () => thickness.Value(),
        interfaceShift,
        surfaceShift,
        () => esd_input.Value(),
    )
})


</script>

<template>
    <div id="jxgbox" class="jxgbox" style="width:600px; height:300px;"></div>
</template>