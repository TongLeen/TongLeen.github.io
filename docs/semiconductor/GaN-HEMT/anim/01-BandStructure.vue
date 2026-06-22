<script setup lang="ts">

import {
    ref,
    onMounted,
    watch,
    computed,
    type Ref,
} from 'vue';


import JXG from 'jsxgraph';


onMounted(() => {
    const board = JXG.JSXGraph.initBoard("jxgbox", {
        boundingBox: [-10, 5, 10, -5],
        showCopyright: false,
        showNavigation: false,
    })

    const unvisiblePoint =
        (parents: unknown[]) =>
            board.create(
                'point', parents,
                { visible: false }
            )

    const s_thickness = board.create(
        'slider',
        [[-8, -4], [0, -4], [0, 0.2, 1]],
        { name: 'thickness' }
    )
    const s_polar = board.create(
        'slider',
        [[-8, -4.5], [0, -4.5], [0, 0.1, 1]],
        { name: 'polarization' }
    )
    const thickness = () => s_thickness.Value() * 8
    const polarization = () => s_polar.Value() * 1.6

    const A = unvisiblePoint([
        () => -thickness() / 2,
        () => (thickness() * polarization() < 2) ? (3 + thickness() * polarization() / 2) : 4,
    ])
    const B = unvisiblePoint([
        () => A.X() + thickness(),
        () => (thickness() * polarization() < 2) ? (A.Y() - thickness() * polarization()) : 2,
    ])

    board.create(
        'segment',
        [A, B],
    )

    const C = unvisiblePoint(
        [
            () => A.X(),
            () => A.Y() - 2,
        ]
    )
    const D = unvisiblePoint(
        [
            () => B.X(),
            () => B.Y() - 2,
        ]
    )
    board.create(
        'segment',
        [C, D]
    )
    board.create(
        'segment',
        [A, C]
    )
    board.create(
        'segment',
        [D, B]
    )

    board.create(
        'line',
        [[0, 2], [1, 2]],
        { strokeColor: 'green', dash: 2, fixed: true }
    )
    board.create(
        'text',
        [5, 2.3, 'EF'],
        { color: 'green' }
    )

    board.create(
        'segment',
        [
            [() => -thickness() / 2 - 0.5, -3],
            [() => thickness() / 2 + 0.5, -3],
        ],
        { strokeColor: 'gray', strokeWidth: 1 }
    )

    const carrier = () => (thickness() * polarization() < 2) ? (0) :
        (polarization() - (2) / thickness()) * 1.4

    board.create(
        'segment',
        [
            [() => -thickness() / 2, -3],
            [() => -thickness() / 2, () => -3 + carrier()],
        ],
        { strokeWidth: 10, strokeColor: 'red' }
    )
    board.create(
        'text',
        [
            () => -thickness() / 2 - 0.1,
            () => -3 + carrier() + 0.2,
            'h'
        ],
        { color: 'red' }
    )

    board.create(
        'segment',
        [
            [() => thickness() / 2, -3],
            [() => thickness() / 2, () => -3 + carrier()],
        ],
        { strokeWidth: 10, strokeColor: 'blue' }
    )
    board.create(
        'text',
        [
            () => thickness() / 2 - 0.1,
            () => -3 + carrier() + 0.2,
            'e',
        ],
        { color: 'blue' }
    )
})


</script>


<template>
    <div id="jxgbox" class="jxgbox" style="width:600px; height:300px;"></div>
</template>
